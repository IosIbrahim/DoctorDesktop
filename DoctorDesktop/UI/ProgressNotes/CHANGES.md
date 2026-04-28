# Progress Notes — Recent Changes

Three changes landed in this pass:

1. Reply feature (now wired to the `DDDocNurseReplySave` POST API)
2. Fix for the "one note appears 3-4 times" duplication bug
3. Reply POST API integration (follow-up that was previously deferred)

---

## 1. Reply feature

### Business rules

- Anyone can reply to any note.
- A note can have **multiple** replies.
- **No reply-on-reply.** Replies are flat — you cannot reply to a reply.
- Reply text is sent to the server via `DDDocNurseReplySave` (see section 3). The optimistic local bubble appears immediately and is replaced by the authoritative `REPLY_ROW` after the post-send reload.

### How it works

- Each parent-note card now shows a "Reply" pill at the bottom-trailing corner.
- Tapping it opens a small `UIAlertController` with a text field.
- Tapping "Send" in the alert calls `presenter.addLocalReply(toNoteSer:body:)`, which appends a `DoctorNurseNoteReply` into the in-memory `localReplies: [String: [DoctorNurseNoteReply]]` dictionary keyed by parent SER.
- The presenter's existing `displayItems` interleaves each parent note with its server-side reply (if any) followed by all local replies, so the new bubble appears immediately under its parent.

### "No reply-on-reply" enforcement

Two independent guards:

1. The Reply pill is built only inside `ProgressNoteRowCell` (parent rows). It is **never** added to `ProgressNoteReplyCell`, so reply rows have no Reply affordance.
2. `presentReplyComposer(parentSer:)` rejects optimistic parents whose SER is missing or `"0"` and shows a "hasn't synced yet" alert. This prevents attaching a reply to a row that doesn't yet have a server identity.

### Files touched

| File | Change |
|------|--------|
| `ProgressNoteRowCell.swift` | Added `replyButton` view, `onReplyTapped` callback, layout + reuse reset, hidden when deleted or SER not yet assigned. |
| `ProgressNotesViewController.swift` | Wired `cell.onReplyTapped` in `cellForRowAt`. Added `presentReplyComposer(parentSer:)`. |
| `ProgressNotesPresenter.swift` | (Already had `addLocalReply` and `displayItems` — no change in this pass.) |

---

## 2. Duplicate-note bug fix

### Symptom

Writing one note from iOS made it appear **3 or 4 times** in the list. Android did not have the bug.

### Root cause analysis

The presenter already had an `isSending` re-entrancy guard, but the lock was released the instant the save callback returned `success`. There was a brief window between:

- the save POST succeeding, and
- the post-save `load()` repopulating `allNotes` with the server's authoritative list

During that window, a fast retap on Send (or the network layer auto-retrying internally) could fire a second save and the server would persist a duplicate.

A second potential source was the server itself returning multiple rows for one save — there was no client-side dedup, so duplicates rendered as-is.

### Fix — two layers of defense

1. **`isSending` stays true through the post-save reload.**
   - New private helper `fetchAndClearSending()` calls `fetch(... clearIsSendingOnDone: true)`.
   - The send button only re-enables once the authoritative list has landed.
   - Closes the rapid-retap window.

2. **SER-based + content-fingerprint dedup on every load.**
   - New static helper `dedupedNotes(_:)` runs on every server response.
   - First pass: collapse rows that share the same non-empty, non-`"0"` `SER`.
   - Second pass (for optimistic / SER-missing rows): collapse by content fingerprint = `visitId | userId | transDate | priorityType | body`.
   - Order is preserved.

### Files touched

| File | Change |
|------|--------|
| `ProgressNotesPresenter.swift` | Added `dedupedNotes(_:)` static helper. Added `clearIsSendingOnDone:` flag on `fetch()`. Added `fetchAndClearSending()` and routed the save-success path through it. |

---

## 3. Reply POST API

### Endpoint

`POST {ip}/MobileApi/api/MedicalRcordController/DDDocNurseReplySave`

OAuth 1.0 HMAC-SHA1 signed (same auth pipeline as the other progress-note endpoints — routed through the existing `signedFormPOST` helper).

### Body (form-urlencoded; three JSON-string fields)

```
SI                   = {"BranchID":1,"ComputerName":"ios","GroupID":"DR","LanguageID":2,"UserID":"<user>"}
DOCTOR_NURSE_REMARKS = [{"BUFFER_STATUS":"1","PARENT_SER":"<parent note SER>","REPLY_DESC":"<text>"}]
DD_UC_PARMS          = {"PATIENT_ID":"<id>","VISIT_ID":"<id>","PROCESS_ID":"2064","TRACER_PLACE_ID":"9","USER_OPEN_FLAG":"D"}
```

`PROCESS_ID=2064` is what distinguishes this from save (`994`) and delete (`4179`) on the server. Response shape matches save: `{"message":"Save Success"}`.

### Flow

1. Reply pill tapped → `presentReplyComposer(parentSer:)` → text alert.
2. User confirms → `presenter.addLocalReply(toNoteSer:body:)`:
   - Optimistic in-memory bubble inserted into `localReplies[parentSer]`, view reloads — user sees the bubble instantly.
   - POST fires.
   - **Success** → `load()` runs; `localReplies` is wiped; the server's `REPLY_ROW` for the parent note now carries the reply.
   - **Failure** → `rollbackLastLocalReply(parentSer:)` removes the optimistic bubble, view reloads, error alert surfaces via `progressNotesDidSend(success:false,…)`.

### Files touched

| File | Change |
|------|--------|
| `NetworkLayer.swift` | Added `saveDoctorNurseReply(with:finished:)` protocol + impl routed through `signedFormPOST` to the new endpoint. |
| `ModelLayer.swift`   | Added `saveDoctorNurseReply(with:finished:)` that parses the `{"message":"Save Success"}` response. |
| `ProgressNotesPresenter.swift` | `addLocalReply(toNoteSer:body:)` now builds the SI / `DOCTOR_NURSE_REMARKS` / `DD_UC_PARMS` payload, fires the POST, reloads on success, rolls back on failure. Added private `rollbackLastLocalReply(parentSer:)` helper. Hardened guard rejects `parentSer == "0"` (unsynced parent). |

---

## Follow-ups (not in this pass)

- Consider rendering a small "pending sync" badge on optimistic notes (SER `"0"`) so the user knows why the Reply pill is briefly hidden.
- If the duplicate-save root cause is confirmed to be server-side, the dedup helper can stay as a belt-and-braces safety net.
- The server still stores **one** `REPLY_ROW` per note. If the requirement evolves to "many replies per note round-tripped from the server", that's a server-side schema change — the client list rendering already supports many replies (the `displayItems` loop iterates `localReplies[ser]`).
