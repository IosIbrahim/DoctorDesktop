# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build / run

This is an iOS app (`DoctorDesktop`) built with CocoaPods. There is no `package.json` / npm tooling and no test target — the app is verified by running it on a device or simulator from Xcode.

- **Always open `DoctorDesktop.xcworkspace`**, never `.xcodeproj` (CocoaPods).
- After pulling, run `pod install` from the repo root if `Podfile.lock` changed. The Pods are checked in but stay in sync with `Podfile`.
- Build / run via Xcode (⌘R). Command-line equivalent:
  `xcodebuild -workspace DoctorDesktop.xcworkspace -scheme DoctorDesktop -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build`

The default API host is hard-coded as `http://41.33.82.156:29804` in `DoctorDesktop/ModelLayer/NetworkLayer/NetworkLayer.swift` (`AppURLS.ip`). A duplicate copy exists in `DoctorDesktop/networkAPi/Constants.swift` (`Constants.APIProvider.baseIP`) — keep them aligned when changing environments.

## High-level architecture

### Layered model (request flow)

```
ViewController ──► Presenter ──► ModelLayer ──► NetworkLayer ──► HTTP
                       ▲              │
                       └── TranslationLayer ◄┘   (raw Data → DTOs)
```

- **`ModelLayer/NetworkLayer/NetworkLayer.swift`** — single class that owns *every* HTTP endpoint (~600 LOC). All requests go through one of three private helpers: `get`, `post`, `postJSON`, plus `signedFormPOST` for OAuth-signed form bodies. Each public method is `func someApi(with params: [String: String], finished: @escaping DataBlock)` and returns raw `Data` — never decoded models. Endpoints live as string concatenations of `AppURLS.ip + "/MobileApi/api/..."`.
- **`ModelLayer/TranslationLayer/TranslationLayer.swift`** — decodes raw `Data` into typed DTOs from `ModelLayer/DTOs/`. Helpers like `decodeArray(_:at:)` walk dotted JSON paths because the server's response shapes are deeply nested (e.g. `Root.DOCTOR_NURSE_REMARKS.DOCTOR_NURSE_REMARKS_ROW`).
- **`ModelLayer/ModelLayer.swift`** — the protocol presenters depend on. Composes `NetworkLayer` + `TranslationLayer` and exposes `(Bool, String?)` / typed-result callbacks. **This is the layer presenters should call**, not `NetworkLayer` directly.
- **DTOs (`ModelLayer/DTOs/`)** — hand-rolled `Decodable` with custom `init(from:)` that wraps every field in `try?`. The server frequently returns the *same* field as a string OR a nested object OR an array (e.g. `REPLY_ROW` is a single object for 1 reply, an array for 2+). Decoders must tolerate all shapes; otherwise one bad row drops the whole list. See `DoctorNurseNotesData.swift` for the canonical pattern.

### OAuth signing

Every server request is OAuth 1.0 HMAC-SHA1 signed:

- Credentials: `consumerKey = "khaber_1"` / `consumerSecret` in `networkAPi/Constants.swift`.
- Signing is delegated to the **OhhAuth** pod via `Constants.getoAuthValue(url:method:parameters:)`.
- `NetworkLayer.signedFormPOST` is the canonical entry point for form-POSTs that need signing — it builds the body via `oauthEncode` per RFC 5849 (the double-encoding bug fixed in commit `619ec2b` is a known sharp edge — do **not** percent-encode the param string twice).

### DI + navigation

- **Swinject** is the DI container. `Injection/DependencyRegistry.swift` (`DependencyRegistryImpl.registerDependencies/Presenters/ViewControllers`) is the **single registration point** — add new presenters and view controllers there.
- The shared container is wired in `Injection/SwinjectStoryboard+Extensions.swift` (`setup()` is called early from `AppDelegate`).
- `AppDelegate.dependencyRegistry` and `AppDelegate.navigationCoordinator` are global statics — code reaches them directly rather than passing them through. The coordinator (`Coordination/RootNavigationCoordinator.swift`) owns the `UINavigationController` and exposes `push(...)` / `movingBack()` helpers.

### UI conventions

- Older screens use **storyboards + Swinject** (`SwinjectStoryboard.defaultContainer`). Newer screens (`UI/ProgressNotes/`, `UI/VitalSignsEntry/`) are **fully programmatic UIKit**, built in `buildUI()` with Auto Layout. Prefer the programmatic pattern for new work — `ProgressNotesViewController` is the reference.
- All new screens follow **MVP**: a `<Foo>Presenter` protocol + `<Foo>PresenterImpl` class, paired with a `<Foo>View` protocol the VC implements. Presenters are stateful (own loaded data + draft state), VCs are dumb renderers. They never import `UIKit` work into the presenter.
- iOS deployment target is old enough that some code still uses pre-iOS-13 APIs (`UIKeyboardWillChangeFrame`, `UIEdgeInsetsInsetRect`, non-namespaced `AVAudioSessionCategoryRecord`). Keep SF Symbol usage gated behind `if #available(iOS 13, *)`.

### Progress Notes module (most actively edited area)

`UI/ProgressNotes/` is the most recently modernised feature and shows the patterns to follow:

- **Endpoint trio**, all OAuth-signed form POSTs differentiated by `PROCESS_ID` in `DD_UC_PARMS`:
  - `DDDocNurseNotesLoad` — fetch (also returns the four lookup arrays in one shot)
  - `DDDocNurseNotesSave` — `PROCESS_ID=994` insert, `PROCESS_ID=4179` + `BUFFER_STATUS=3` soft-delete (same endpoint, server dispatches by flag)
  - `DDDocNurseReplySave` — `PROCESS_ID=2064` reply insert
- **Optimistic UI + reload**: `send`/`addLocalReply`/`deleteNote` insert into in-memory state, fire the POST, and on success call `load()` to replace optimistic rows with the server's authoritative list. On failure they roll the optimistic insert back. The `isSending` re-entrancy guard stays `true` until the post-save reload lands — closing the rapid-retap window that previously created 3-4 duplicate rows.
- **Defensive dedup**: `ProgressNotesPresenter.dedupedNotes(_:)` collapses duplicates by SER, falling back to a content fingerprint for optimistic rows (SER missing or `"0"`).
- **Voice / dictation**: `SpeechDictation.swift` wraps `SFSpeechRecognizer` + `AVAudioEngine`. Each consumer (`ProgressNotesViewController`, `ReplyComposerViewController`) owns its own instance and implements `SpeechDictationDelegate` — never share one across screens.
- `CHANGES.md` in this folder documents recent design + API decisions.

### Lite-APP branch — lightweight mode

Branch `Lite-APP` is a stripped-down variant of the app. It shares all the same code as `Refactoring-by-Hamdi` but replaces the full 18-section Overview grid with a minimal two-screen flow:

```
PatientsList → LiteOverviewViewController → ProgressNotesViewController
```

**`UI/Overview/LiteOverview/LiteOverviewViewController.swift`** (programmatic, new file)
- Registered in Xcode via manually added `project.pbxproj` entries (group `LiteOverview` inside `Overview`).
- `configure(with presenter: OverviewPresenter, navigationCoordinator: NavigationCoordinator)` — no storyboard, no extra dependencies.
- Loads only `getVisitsDetail` + `getPatientHistory` (fills `PatientHeaderView` chips). `getPatientSummary` is intentionally never called.
- Shows a single "Remarks" card below the header. Tapping it calls `coordinator.next(arguments:)` with `overviewSection: .progressNotes` — the existing `showOverviewSectionDetails` path in `RootNavigationCoordinator` handles the push to `ProgressNotesViewController`.

**Coordinator wiring (`Coordination/RootNavigationCoordinator.swift`)**
- `showOverviewCollection` pushes `LiteOverviewViewController` instead of `OverviewCollectionViewController`.
- `navState` is set to `.atOverviewCollection` on push, so `next()` correctly routes to `showOverviewSectionDetails` on Remarks tap.
- `movingBack()` from `.atOverviewCollection` returns to `.atPatientList` — standard back navigation works unchanged.

**DI (`Injection/DependencyRegistry.swift`)**
- `registerLiteOverviewViewController()` / `makeLiteOverviewViewController(with:user:permission:)` added at the bottom of the file.
- Only resolves `OverviewPresenter` — does **not** pre-create a `ProgressNotesViewController` (the coordinator creates it on tap).

**`ProgressNoteRowCell` changes (Lite-APP only)**
- Redesigned: initials badge, inline date, outlined priority chip, lighter shadow/border.
- Left accent bar removed (was teal/red strip signalling priority — user-requested removal).
- Reply bubble (`ProgressNoteReplyCell`) unchanged.

## Pitfalls / repeat-incident notes

- **REPLY_ROW shape switches with count.** The server sends `REPLY_ROW` as a single object when there is 1 reply and as an array when there are 2+. DTOs must try array decode first then fall back to single-object — see `ReplyEnvelope` in `DoctorNurseNotesData.swift`. This pattern likely repeats elsewhere in the API; check before assuming a JSON field is consistently shaped.
- **Two parallel network stacks coexist.** `DoctorDesktop/networkAPi/` is the legacy direct-Alamofire layer; `DoctorDesktop/ModelLayer/NetworkLayer/` is the newer OAuth-signed layer. New endpoints go in `NetworkLayer.swift`. The legacy `Constants.APIProvider.*` URL strings are still referenced from older screens — do not delete them blindly.
- **Tolerant decoding is mandatory.** Every DTO field uses `try?` because a single mistyped/missing field server-side has historically dropped entire response arrays. Don't switch to the synthesized `Decodable` init.
- **OAuth param signing.** `oauthEncode` is the percent-encoder that matches the server's RFC 5849 expectations. Encoding the param string twice produces a 401 — the symptom is "auth was working yesterday and now isn't on a new endpoint."
