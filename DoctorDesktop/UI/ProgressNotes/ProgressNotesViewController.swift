//
//  ProgressNotesViewController.swift
//  DoctorDesktop
//
//  Dedicated progress-notes screen (replaces the legacy shared
//  OverviewSectionDetails flow for `.progressNotes`).
//
//  Layout (top → bottom):
//    • Patient header card (teal), matching the vitals-history screen style.
//    • "Progress Notes" title + filter pill.
//    • Notes list (ProgressNoteRowCell — redesigned to match the Android card).
//    • Bottom composer bar with:
//        – Text field
//        – Mic button (record/playback voice note)
//        – 3 action buttons: [Show-to] [Priority] [Send]
//
//  Built programmatically (no XIB) following the VitalSignsEntryViewController pattern.
//

import UIKit
import AVFoundation

final class ProgressNotesViewController: UIViewController {

    // MARK: - Dependencies

    var presenter: ProgressNotesPresenter!
    private weak var navigationCoordinator: NavigationCoordinator?

    // MARK: - Subviews

    private let headerCard       = UIView()
    private let headerName       = UILabel()
    private let headerSubtitle   = UILabel()
    private let headerIcon       = UIImageView()

    private let titleLabel       = UILabel()
    private let filterPill       = UIButton(type: .system)

    private let tableView        = UITableView(frame: .zero, style: .plain)
    private let emptyLabel       = UILabel()

    private let composerBar      = UIView()
    private let textField        = UITextField()
    private let micButton        = UIButton(type: .system)
    private let showToButton     = UIButton(type: .system)
    private let priorityButton   = UIButton(type: .system)
    private let sendButton       = UIButton(type: .system)
    private let recordingLabel   = UILabel()

    // MARK: - State

    /// Live speech → text dictation driven by the mic button.
    private let dictation = SpeechDictation()
    /// Text that was already in the field before dictation started — partial
    /// transcripts are appended to this snapshot, so the user never loses text
    /// they typed manually.
    private var preDictationText: String = ""
    private var composerBottomConstraint: NSLayoutConstraint!

    // MARK: - Colours

    private let teal       = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
    private let pillBG     = UIColor(red: 0.94, green: 0.97, blue: 0.96, alpha: 1)
    private let pillBorder = UIColor(red: 0.86, green: 0.91, blue: 0.90, alpha: 1)
    private let urgent     = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)
    private let bgColor    = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    private let chipText   = UIColor(red: 0.22, green: 0.26, blue: 0.32, alpha: 1)

    /// Small red dot that appears on the filter pill when a filter is active.
    private let filterActiveDot = UIView()

    // MARK: - Configure

    func configure(with presenter: ProgressNotesPresenter,
                   navigationCoordinator: NavigationCoordinator) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        title = "Progress Notes"
        dictation.delegate = self
        buildUI()
        registerKeyboardObservers()
        presenter.attach(view: self)
        renderHeader()
        updateComposerChips()
        presenter.load()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            dictation.cancel()
            navigationCoordinator?.movingBack()
        }
    }

    // MARK: - UI

    private func buildUI() {
        // Header card
        headerCard.backgroundColor = teal
        headerCard.layer.cornerRadius = 10
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerCard)

        headerIcon.translatesAutoresizingMaskIntoConstraints = false
        headerIcon.tintColor = .white
        headerIcon.contentMode = .scaleAspectFit
        if #available(iOS 13, *) {
            headerIcon.image = UIImage(systemName: "person.crop.circle.fill")
        }
        headerCard.addSubview(headerIcon)

        headerName.translatesAutoresizingMaskIntoConstraints = false
        headerName.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        headerName.textColor = .white
        headerCard.addSubview(headerName)

        headerSubtitle.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        headerSubtitle.textColor = UIColor.white.withAlphaComponent(0.9)
        headerCard.addSubview(headerSubtitle)

        // Title + filter row
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.25, alpha: 1)
        titleLabel.text = "Progress Notes"
        view.addSubview(titleLabel)

        styleChipButton(filterPill, title: "Filter", systemIcon: "line.horizontal.3.decrease")
        filterPill.translatesAutoresizingMaskIntoConstraints = false
        filterPill.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        // When a filter is active the pill becomes "Filter: <selection>" — long
        // selections used to render as "Doctors • A…" because the chip was
        // letting itself be compressed. Lock it to its intrinsic width.
        filterPill.titleLabel?.lineBreakMode = .byClipping
        filterPill.titleLabel?.adjustsFontSizeToFitWidth = false
        filterPill.setContentCompressionResistancePriority(.required, for: .horizontal)
        filterPill.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.addSubview(filterPill)

        // Active-filter dot (small red circle pinned to the pill's top-right)
        filterActiveDot.backgroundColor = urgent
        filterActiveDot.layer.cornerRadius = 4
        filterActiveDot.layer.borderColor  = UIColor.white.cgColor
        filterActiveDot.layer.borderWidth  = 1.5
        filterActiveDot.translatesAutoresizingMaskIntoConstraints = false
        filterActiveDot.isHidden = true
        view.addSubview(filterActiveDot)

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(ProgressNoteRowCell.self,   forCellReuseIdentifier: ProgressNoteRowCell.reuseId)
        tableView.register(ProgressNoteReplyCell.self, forCellReuseIdentifier: ProgressNoteReplyCell.reuseId)
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No progress notes yet."
        emptyLabel.textColor = UIColor(white: 0.55, alpha: 1)
        emptyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        // Composer bar
        composerBar.translatesAutoresizingMaskIntoConstraints = false
        composerBar.backgroundColor = .white
        composerBar.layer.shadowColor   = UIColor.black.cgColor
        composerBar.layer.shadowOpacity = 0.06
        composerBar.layer.shadowRadius  = 6
        composerBar.layer.shadowOffset  = CGSize(width: 0, height: -2)
        view.addSubview(composerBar)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Write a note…"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.returnKeyType = .send
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        composerBar.addSubview(textField)

        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
        recordingLabel.text = ""
        recordingLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        recordingLabel.textColor = urgent
        recordingLabel.isHidden = true
        composerBar.addSubview(recordingLabel)

        styleIconButton(micButton, systemIcon: "mic.fill", tint: teal)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.addTarget(self, action: #selector(didTapMic), for: .touchUpInside)
        composerBar.addSubview(micButton)

        // Show-to: ICON ONLY (no label) per design — the eye glyph alone
        // signals "who can see this". Tap still opens the show-to picker.
        styleIconOnlyChipButton(showToButton, systemIcon: "eye")
        showToButton.translatesAutoresizingMaskIntoConstraints = false
        showToButton.addTarget(self, action: #selector(didTapShowTo), for: .touchUpInside)
        composerBar.addSubview(showToButton)

        styleChipButton(priorityButton, title: "Normal", systemIcon: "flag.fill")
        priorityButton.translatesAutoresizingMaskIntoConstraints = false
        priorityButton.addTarget(self, action: #selector(didTapPriority), for: .touchUpInside)
        // Don't let layout squeeze "Normal" / "Urgent" into "N…al".
        priorityButton.titleLabel?.lineBreakMode = .byClipping
        priorityButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        priorityButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        composerBar.addSubview(priorityButton)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("  Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sendButton.backgroundColor = teal
        sendButton.layer.cornerRadius = 18
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 18)
        sendButton.layer.shadowColor   = teal.cgColor
        sendButton.layer.shadowOpacity = 0.28
        sendButton.layer.shadowRadius  = 6
        sendButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        if #available(iOS 13, *) {
            sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
            sendButton.tintColor = .white
            sendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
        }
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        composerBar.addSubview(sendButton)

        // Layout
        let guide = view.safeAreaLayoutGuide
        composerBottomConstraint = composerBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor)

        NSLayoutConstraint.activate([
            // Header
            headerCard.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            headerCard.heightAnchor.constraint(equalToConstant: 64),

            headerIcon.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 14),
            headerIcon.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            headerIcon.widthAnchor.constraint(equalToConstant: 36),
            headerIcon.heightAnchor.constraint(equalToConstant: 36),

            headerName.leadingAnchor.constraint(equalTo: headerIcon.trailingAnchor, constant: 12),
            headerName.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -14),
            headerName.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 14),

            headerSubtitle.leadingAnchor.constraint(equalTo: headerName.leadingAnchor),
            headerSubtitle.trailingAnchor.constraint(equalTo: headerName.trailingAnchor),
            headerSubtitle.topAnchor.constraint(equalTo: headerName.bottomAnchor, constant: 2),

            // Title + filter
            titleLabel.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            filterPill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            filterPill.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            filterPill.heightAnchor.constraint(equalToConstant: 32),

            filterActiveDot.widthAnchor.constraint(equalToConstant: 10),
            filterActiveDot.heightAnchor.constraint(equalToConstant: 10),
            filterActiveDot.trailingAnchor.constraint(equalTo: filterPill.trailingAnchor, constant: 2),
            filterActiveDot.topAnchor.constraint(equalTo: filterPill.topAnchor, constant: -2),

            // Table
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: composerBar.topAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),

            // Composer
            composerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerBottomConstraint,

            textField.topAnchor.constraint(equalTo: composerBar.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: composerBar.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 36),

            micButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            micButton.trailingAnchor.constraint(equalTo: composerBar.trailingAnchor, constant: -12),
            micButton.widthAnchor.constraint(equalToConstant: 36),
            micButton.heightAnchor.constraint(equalToConstant: 36),

            recordingLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 2),
            recordingLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 4),

            showToButton.topAnchor.constraint(equalTo: recordingLabel.bottomAnchor, constant: 6),
            showToButton.leadingAnchor.constraint(equalTo: composerBar.leadingAnchor, constant: 12),
            showToButton.heightAnchor.constraint(equalToConstant: 30),
            showToButton.bottomAnchor.constraint(equalTo: composerBar.bottomAnchor, constant: -10),

            priorityButton.centerYAnchor.constraint(equalTo: showToButton.centerYAnchor),
            priorityButton.leadingAnchor.constraint(equalTo: showToButton.trailingAnchor, constant: 8),
            priorityButton.heightAnchor.constraint(equalToConstant: 30),

            sendButton.centerYAnchor.constraint(equalTo: showToButton.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: composerBar.trailingAnchor, constant: -12),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func styleChipButton(_ btn: UIButton, title: String, systemIcon: String) {
        btn.backgroundColor = pillBG
        btn.setTitleColor(chipText, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth  = 1
        btn.layer.borderColor  = pillBorder.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn.setTitle(title, for: .normal)
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            btn.setImage(UIImage(systemName: systemIcon, withConfiguration: cfg), for: .normal)
            btn.tintColor = teal
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        }
    }

    /// Small circular chip with an SF Symbol and NO title — used for the
    /// show-to selector where the eye glyph carries the meaning on its own.
    private func styleIconOnlyChipButton(_ btn: UIButton, systemIcon: String) {
        btn.backgroundColor = pillBG
        btn.setTitle(nil, for: .normal)
        btn.layer.cornerRadius = 15        // matches 30pt height
        btn.layer.borderWidth  = 1
        btn.layer.borderColor  = pillBorder.cgColor
        btn.contentEdgeInsets  = .zero
        btn.imageEdgeInsets    = .zero
        btn.titleEdgeInsets    = .zero
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            btn.setImage(UIImage(systemName: systemIcon, withConfiguration: cfg), for: .normal)
            btn.tintColor = teal
        }
        // Make it a square pill — matches the priority chip's height.
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    private func styleIconButton(_ btn: UIButton, systemIcon: String, tint: UIColor) {
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            btn.setImage(UIImage(systemName: systemIcon, withConfiguration: cfg), for: .normal)
        }
        btn.tintColor = tint
        btn.backgroundColor = pillBG
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth  = 1
        btn.layer.borderColor  = pillBorder.cgColor
    }

    // MARK: - Rendering

    private func renderHeader() {
        guard let patient = presenter?.patient else { return }
        headerName.text = patient.name.isEmpty ? "-" : patient.name
        let nat = patient.nationality
        let date = patient.date
        if !nat.isEmpty && !date.isEmpty { headerSubtitle.text = "\(nat) • \(date)" }
        else if !nat.isEmpty             { headerSubtitle.text = nat }
        else                             { headerSubtitle.text = date }
    }

    private func updateComposerChips() {
        // Show-to is icon-only by design — the chosen audience is conveyed by
        // the picker sheet, not a chip label. Keep the title nil and just
        // update the accessibility hint so VoiceOver still announces the
        // current selection.
        showToButton.setTitle(nil, for: .normal)
        showToButton.accessibilityLabel = "Show to: \(presenter.draftShowToLabel)"

        // Priority chip — red theme when urgent, teal otherwise.
        priorityButton.setTitle(presenter.draftPriorityLabel, for: .normal)
        let isUrgent = presenter.isUrgentPriority
        priorityButton.backgroundColor     = isUrgent ? urgent.withAlphaComponent(0.10) : pillBG
        priorityButton.layer.borderColor   = (isUrgent ? urgent.withAlphaComponent(0.35)
                                                       : pillBorder).cgColor
        priorityButton.setTitleColor(isUrgent ? urgent : chipText, for: .normal)
        priorityButton.tintColor = isUrgent ? urgent : teal
    }

    /// Updates the filter pill to reflect the active filter state.
    /// - Idle   → "Filter" in neutral gray, no dot.
    /// - Active → label shows the active selection, pill tinted teal, red dot visible.
    private func updateFilterPill() {
        let vt = presenter.activeVisitTypeLabel
        let f  = presenter.activeFilterLabel
        let hasFilter = (presenter.activeVisitTypeId != "" || presenter.activeFilterId != "")
        if hasFilter {
            // Only include non-"All" labels in the title to keep it short.
            let parts = [vt, f].filter { $0 != "All" && $0 != "My View" }
            let title = parts.isEmpty ? "Filtered" : parts.joined(separator: " • ")
            filterPill.setTitle(title, for: .normal)
            filterPill.backgroundColor     = teal.withAlphaComponent(0.12)
            filterPill.layer.borderColor   = teal.withAlphaComponent(0.35).cgColor
            filterPill.setTitleColor(teal, for: .normal)
            filterPill.tintColor = teal
            filterActiveDot.isHidden = false
        } else {
            filterPill.setTitle("Filter", for: .normal)
            filterPill.backgroundColor     = pillBG
            filterPill.layer.borderColor   = pillBorder.cgColor
            filterPill.setTitleColor(chipText, for: .normal)
            filterPill.tintColor = teal
            filterActiveDot.isHidden = true
        }
    }

    // MARK: - Actions

    /// Shows the Android-matched bottom sheet with two dropdowns:
    ///   • Filter   → VISIT_TYPE_ROW   (Inpatient / Outpatient / Emergency)
    ///   • Visit Type → NURSE_REMARKS_FILTER_ROW (My View / Doctors / Nursing / …)
    @objc private func didTapFilter() {
        view.endEditing(true)
        let sheet = ProgressNotesFilterSheet()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle   = .crossDissolve

        // Use presenter data. If the API hasn't responded yet, fall back to
        // hardcoded values so the picker is never empty.
        sheet.visitTypeOptions = presenter.visitTypes.isEmpty
            ? [NurseNoteLookup(id: "1", label: "Inpatient"),   // VISIT_TYPE_ROW fallback
               NurseNoteLookup(id: "2", label: "Outpatient"),
               NurseNoteLookup(id: "3", label: "Emergency")]
            : presenter.visitTypes   // live API data — no synthetic "All" row

        sheet.filterOptions = presenter.filters.isEmpty
            ? [NurseNoteLookup(id: "0",  label: "My View"),
               NurseNoteLookup(id: "1",  label: "Doctors"),
               NurseNoteLookup(id: "2",  label: "Nursing"),
               NurseNoteLookup(id: "4",  label: "Clinical Pharmacy"),
               NurseNoteLookup(id: "5",  label: "Clinical Nutrition Specialists"),
               NurseNoteLookup(id: "6",  label: "Infection Control"),
               NurseNoteLookup(id: "3",  label: "All")]
            : presenter.filters

        sheet.initialVisitTypeId = presenter.activeVisitTypeId
        sheet.initialFilterId    = presenter.activeFilterId
        sheet.delegate = self
        present(sheet, animated: false)
    }

    /// Show-to uses NURSE_REMARKS_SHOW_D_N_ROW — sets who can see the note being composed.
    @objc private func didTapShowTo() {
        // Guaranteed fallback so the picker always shows something even when
        // the API hasn't loaded yet.
        let list: [NurseNoteLookup] = presenter.showToList.isEmpty
            ? [NurseNoteLookup(id: "0", label: "All"),
               NurseNoteLookup(id: "1", label: "Doctors"),
               NurseNoteLookup(id: "2", label: "Nursing"),
               NurseNoteLookup(id: "3", label: "Clinical Pharmacy"),
               NurseNoteLookup(id: "4", label: "Clinical Nutrition Specialists"),
               NurseNoteLookup(id: "5", label: "Infection Control")]
            : presenter.showToList

        presentLookupPicker(title: "Show to", items: list,
                            selectedId: presenter.draftShowToId) { [weak self] item in
            self?.presenter.draftShowToId = item.id
            self?.updateComposerChips()
        }
    }

    /// Priority uses NURSE_REMARKS_PRIORITY_ROW — sets the priority of the note being composed.
    @objc private func didTapPriority() {
        let list: [NurseNoteLookup] = presenter.priorities.isEmpty
            ? [NurseNoteLookup(id: "1", label: "Normal"),
               NurseNoteLookup(id: "3", label: "Urgent")]
            : presenter.priorities

        presentLookupPicker(title: "Priority", items: list,
                            selectedId: presenter.draftPriorityId) { [weak self] item in
            self?.presenter.draftPriorityId = item.id
            self?.updateComposerChips()
        }
    }

    /// Presents a bottom-of-screen UIPickerView (never a UIAlertController) so
    /// that all items always appear regardless of presentation context.
    private func presentLookupPicker(title: String,
                                     items: [NurseNoteLookup],
                                     selectedId: String,
                                     onPick: @escaping (NurseNoteLookup) -> Void) {
        view.endEditing(true)
        let picker = SimpleLookupPickerSheet()
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle   = .crossDissolve
        picker.pickerTitle = title
        picker.items       = items
        picker.selectedId  = selectedId
        picker.onPick      = onPick
        present(picker, animated: false)
    }

    @objc private func textChanged() {
        presenter.draftText = textField.text ?? ""
    }

    @objc private func didTapSend() {
        view.endEditing(true)
        // Snapshot the current text into the presenter BEFORE clearing the
        // field. Clearing immediately prevents the duplicate-send bug where
        // a rapid second tap would re-pull the (still-populated) field into
        // draftText and fire another POST while the first was in flight.
        presenter.draftText = textField.text ?? ""
        textField.text = ""
        preDictationText = ""
        // Visually + functionally lock the send button until the POST resolves.
        // The presenter's internal `isSending` guard is the real defence; this
        // is just user feedback that the tap was registered.
        setSendButtonEnabled(false)
        presenter.send()
        // If the presenter rejected the send (empty text, already in flight),
        // its `isSending` will be false and we should re-enable straight away.
        if !presenter.isSending {
            setSendButtonEnabled(true)
        }
    }

    /// Updates the send button's enabled-state and visual appearance.
    private func setSendButtonEnabled(_ enabled: Bool) {
        sendButton.isEnabled = enabled
        sendButton.alpha     = enabled ? 1.0 : 0.5
    }

    /// Mic button toggles live speech-to-text dictation. When active, the user
    /// speaks and the transcription is streamed into the text field.
    @objc private func didTapMic() {
        if dictation.isRunning {
            stopDictation()
            return
        }
        // Ensure we don't clobber text the user already typed.
        preDictationText = textField.text ?? ""
        dictation.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.presentAlert("Microphone and Speech Recognition access are required to dictate notes. Enable them in Settings.")
                return
            }
            self.dictation.start()
            if self.dictation.isRunning {
                self.showDictationRunningState()
            } else {
                self.presentAlert("Could not start speech recognition.")
            }
        }
    }

    /// Stops the active dictation session. The recognizer may still emit a
    /// final delegate callback shortly after, which we handle gracefully.
    private func stopDictation() {
        dictation.stop()
        showDictationIdleState()
    }

    private func showDictationRunningState() {
        recordingLabel.isHidden = false
        recordingLabel.text     = "● Listening…"
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            micButton.setImage(UIImage(systemName: "stop.fill", withConfiguration: cfg),
                               for: .normal)
            micButton.tintColor = urgent
            micButton.layer.borderColor = urgent.withAlphaComponent(0.35).cgColor
        }
    }

    private func showDictationIdleState() {
        recordingLabel.isHidden = true
        recordingLabel.text     = ""
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            micButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: cfg),
                               for: .normal)
            micButton.tintColor = teal
            micButton.layer.borderColor = pillBorder.cgColor
        }
        micButton.transform = .identity
    }

    // MARK: - Helpers

    private func presentAlert(_ msg: String) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: - Keyboard

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillChange(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }

    @objc private func kbWillChange(_ note: Notification) {
        guard let endFrame = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let screenH = UIScreen.main.bounds.height
        let overlap = max(0, screenH - endFrame.origin.y)
        let safeBottom = view.safeAreaInsets.bottom
        composerBottomConstraint.constant = -max(0, overlap - safeBottom)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    @objc private func kbWillHide(_ note: Notification) {
        composerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension ProgressNotesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Each note + its (optional) reply each get their own row, so the
        // count comes from `displayItems` rather than `notes` directly.
        return presenter?.displayItems.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = presenter.displayItems[indexPath.row]
        switch item {
        case .note(let note):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgressNoteRowCell.reuseId,
                                                     for: indexPath) as! ProgressNoteRowCell
            cell.configure(with: note)
            // Snapshot the SER (not the IndexPath — rows can shift between the
            // tap and the callback) so the presenter can find the right row
            // to soft-delete or attach a reply to.
            let ser = note.ser
            cell.onDeleteTapped = { [weak self] in
                self?.confirmDelete(ser: ser)
            }
            cell.onReplyTapped = { [weak self] in
                self?.presentReplyComposer(parentSer: ser)
            }
            return cell

        case .reply(let reply, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgressNoteReplyCell.reuseId,
                                                     for: indexPath) as! ProgressNoteReplyCell
            cell.configure(with: reply)
            return cell
        }
    }

    /// Presents a small text-input alert for composing a reply to a parent note.
    /// The reply lives only on this device for now (presenter.addLocalReply is
    /// in-memory only) — the POST API will be wired in a follow-up.
    /// Reply-on-reply is forbidden by design: this is only invoked from
    /// `ProgressNoteRowCell` (parent notes), never from `ProgressNoteReplyCell`.
    private func presentReplyComposer(parentSer: String?) {
        guard let ser = parentSer, !ser.isEmpty, ser != "0" else {
            // Optimistic / unsynced parent — bail. Reply needs a real SER so it
            // can be re-attached to the right row when the server reloads.
            presentAlert("This note hasn't synced yet. Please wait a moment and try again.")
            return
        }
        // Custom modal (replaces the old UIAlertController) so the user gets
        // a multi-line text view + a mic button for live speech-to-text,
        // matching the main composer.
        let composer = ReplyComposerViewController()
        composer.onSubmit = { [weak self] body in
            guard let self = self, let body = body else { return }
            self.presenter.addLocalReply(toNoteSer: ser, body: body)
        }
        present(composer, animated: true)
    }

    /// Presents a two-button alert before soft-deleting a note. Matches the
    /// Android flow where the user must confirm before the strikethrough lands.
    private func confirmDelete(ser: String?) {
        let alert = UIAlertController(
            title: "Delete Note?",
            message: "This note will be marked as deleted and shown with a strikethrough.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            // Resolve the current index from the (stable) SER so shifts in the
            // list during the confirmation don't trigger the wrong delete.
            guard let idx = self.presenter.notes.firstIndex(where: { $0.ser == ser }) else {
                return
            }
            self.presenter.deleteNote(at: idx)
        })
        present(alert, animated: true)
    }
}

// MARK: - ProgressNotesView

extension ProgressNotesViewController: ProgressNotesView {
    func progressNotesDidReload() {
        // Drive the empty state from `notes` (i.e. parent rows only) — when
        // there are notes but no replies the table still has content.
        let noteCount = presenter.notes.count
        let rowCount  = presenter.displayItems.count
        print("[ProgressNotes] VC progressNotesDidReload → \(noteCount) notes / \(rowCount) rows → reloading tableView")
        emptyLabel.isHidden = (noteCount > 0)
        tableView.reloadData()
        updateComposerChips()
        updateFilterPill()
    }

    func progressNotesDidSend(success: Bool, message: String?) {
        // Re-enable send regardless of outcome (paired with `setSendButtonEnabled(false)`
        // in didTapSend).
        setSendButtonEnabled(true)
        if success {
            textField.text = ""
            preDictationText = ""
            dictation.cancel()
            showDictationIdleState()
        }
        if let msg = message, !success { presentAlert(msg) }
    }
}

// MARK: - ProgressNotesFilterSheetDelegate

extension ProgressNotesViewController: ProgressNotesFilterSheetDelegate {
    func filterSheet(_ sheet: ProgressNotesFilterSheet,
                     didApply visitTypeId: String,
                     filterId: String) {
        presenter.applyFilter(visitTypeId: visitTypeId, filterId: filterId)
        // updateFilterPill() is called inside progressNotesDidReload
    }

    func filterSheetDidReset(_ sheet: ProgressNotesFilterSheet) {
        presenter.resetFilter()
    }
}

// MARK: - UITextFieldDelegate

extension ProgressNotesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}

// MARK: - SpeechDictationDelegate

extension ProgressNotesViewController: SpeechDictationDelegate {

    /// Live partial / final transcription — splice into the text field after
    /// whatever the user had typed before starting dictation.
    func speechDictation(_ dictation: SpeechDictation,
                         didUpdateTranscription text: String,
                         isFinal: Bool) {
        // If pre-existing text ends with non-space, add a separator.
        let joiner: String
        if preDictationText.isEmpty {
            joiner = ""
        } else if preDictationText.hasSuffix(" ") || preDictationText.hasSuffix("\n") {
            joiner = ""
        } else {
            joiner = " "
        }
        let merged = preDictationText + joiner + text
        textField.text = merged
        presenter.draftText = merged

        if isFinal {
            // The recognizer signalled end-of-utterance; reset UI to idle.
            showDictationIdleState()
            // Commit the recognized text to the baseline so further dictation
            // sessions append to it (don't overwrite).
            preDictationText = merged
        }
    }

    func speechDictation(_ dictation: SpeechDictation, didFailWith message: String) {
        showDictationIdleState()
        presentAlert("Speech recognition failed: \(message)")
    }
}

// MARK: - SimpleLookupPickerSheet
//
// Reusable bottom-of-screen picker. Used for Show-to and Priority.
//
// Implementation: checkmark-list UITableView (not UIPickerView wheel) — this
// matches the ProgressNotesFilterSheet option panel and reads as more modern
// than a spinning drum. Tap a row → commits the selection and dismisses.

final class SimpleLookupPickerSheet: UIViewController,
                                     UITableViewDataSource,
                                     UITableViewDelegate {

    var pickerTitle: String = ""
    var items:       [NurseNoteLookup] = []
    var selectedId:  String = ""
    var onPick:      ((NurseNoteLookup) -> Void)?

    private let dimView   = UIView()
    private let panel     = UIView()
    private let grabber   = UIView()
    private let titleLbl  = UILabel()
    private let cancelBtn = UIButton(type: .system)
    private let table     = UITableView(frame: .zero, style: .plain)

    private static let cellId = "LookupCell"

    private var panelBottomConstraint: NSLayoutConstraint!
    private let rowHeight:    CGFloat = 52
    private let headerHeight: CGFloat = 56

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Scroll the selected row into view.
        if let idx = items.firstIndex(where: { $0.id == selectedId }) {
            table.scrollToRow(at: IndexPath(row: idx, section: 0),
                              at: .middle, animated: false)
        }
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3,
                       options: [], animations: {
            self.dimView.alpha = 1
            self.panelBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    private func buildUI() {
        // Dim overlay — tap to cancel.
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didCancel)))

        // Panel (rounded top corners, soft shadow).
        panel.backgroundColor = .white
        panel.layer.cornerRadius = 20
        panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panel.layer.shadowColor   = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.10
        panel.layer.shadowRadius  = 12
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didCancel))
        swipe.direction = .down
        panel.addGestureRecognizer(swipe)

        // Grabber handle.
        grabber.backgroundColor = UIColor(white: 0.80, alpha: 1)
        grabber.layer.cornerRadius = 2.5
        grabber.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(grabber)

        // Title.
        titleLbl.text = pickerTitle
        titleLbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl.textColor = UIColor(white: 0.10, alpha: 1)
        titleLbl.textAlignment = .center
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(titleLbl)

        // Cancel text-button.
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cancelBtn.setTitleColor(UIColor(white: 0.40, alpha: 1), for: .normal)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        panel.addSubview(cancelBtn)

        // Divider under title.
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.92, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(divider)

        // Options table.
        table.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        table.dataSource = self
        table.delegate   = self
        table.rowHeight  = rowHeight
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        table.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(table)

        // Fit panel: header + up to 6 visible rows, rest scrolls.
        let maxRows = CGFloat(min(items.count, 6))
        let panelH  = headerHeight + maxRows * rowHeight + 16
        panelBottomConstraint = panel.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                              constant: panelH)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelBottomConstraint,
            panel.heightAnchor.constraint(equalToConstant: panelH),

            grabber.topAnchor.constraint(equalTo: panel.topAnchor, constant: 10),
            grabber.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 40),
            grabber.heightAnchor.constraint(equalToConstant: 5),

            titleLbl.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 10),
            titleLbl.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            titleLbl.leadingAnchor.constraint(greaterThanOrEqualTo: panel.leadingAnchor, constant: 60),
            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: panel.trailingAnchor, constant: -60),

            cancelBtn.centerYAnchor.constraint(equalTo: titleLbl.centerYAnchor),
            cancelBtn.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),

            divider.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            table.topAnchor.constraint(equalTo: divider.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -16),
        ])
    }

    @objc private func didCancel() { slideDown(completion: nil) }

    private func slideDown(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.22, animations: {
            self.dimView.alpha = 0
            self.panelBottomConstraint.constant = self.panel.bounds.height
            self.view.layoutIfNeeded()
        }, completion: { _ in
            super.dismiss(animated: false, completion: completion)
        })
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        slideDown(completion: completion)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        guard indexPath.row < items.count else { return cell }
        let item = items[indexPath.row]

        cell.textLabel?.text  = item.label
        cell.textLabel?.font  = UIFont.systemFont(ofSize: 15, weight: .regular)
        cell.textLabel?.textColor = UIColor(white: 0.15, alpha: 1)
        cell.accessoryType    = (item.id == selectedId) ? .checkmark : .none
        cell.tintColor        = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
        cell.selectionStyle   = .default
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else { return }
        let item = items[indexPath.row]
        selectedId = item.id
        tableView.reloadData()
        // Brief delay so the user registers the checkmark before the sheet dismisses.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.slideDown { self?.onPick?(item) }
        }
    }
}
