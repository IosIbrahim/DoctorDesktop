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

    private let recorder = VoiceNoteRecorder()
    private var composerBottomConstraint: NSLayoutConstraint!

    // MARK: - Colours

    private let teal     = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
    private let pillBG   = UIColor(red: 0.94, green: 0.97, blue: 0.96, alpha: 1)
    private let urgent   = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)
    private let bgColor  = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)

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
        recorder.delegate = self
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
            recorder.discardRecording()
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

        styleChipButton(filterPill, title: "All", systemIcon: "line.horizontal.3.decrease")
        filterPill.translatesAutoresizingMaskIntoConstraints = false
        filterPill.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        view.addSubview(filterPill)

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(ProgressNoteRowCell.self, forCellReuseIdentifier: ProgressNoteRowCell.reuseId)
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

        styleChipButton(showToButton, title: "Show to: All", systemIcon: "eye")
        showToButton.translatesAutoresizingMaskIntoConstraints = false
        showToButton.addTarget(self, action: #selector(didTapShowTo), for: .touchUpInside)
        composerBar.addSubview(showToButton)

        styleChipButton(priorityButton, title: "Normal", systemIcon: "flag.fill")
        priorityButton.translatesAutoresizingMaskIntoConstraints = false
        priorityButton.addTarget(self, action: #selector(didTapPriority), for: .touchUpInside)
        composerBar.addSubview(priorityButton)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sendButton.backgroundColor = teal
        sendButton.layer.cornerRadius = 18
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
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
            filterPill.heightAnchor.constraint(equalToConstant: 30),

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
        btn.setTitleColor(UIColor(white: 0.25, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        btn.layer.cornerRadius = 15
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.setTitle(title, for: .normal)
        if #available(iOS 13, *) {
            btn.setImage(UIImage(systemName: systemIcon), for: .normal)
            btn.tintColor = teal
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        }
    }

    private func styleIconButton(_ btn: UIButton, systemIcon: String, tint: UIColor) {
        if #available(iOS 13, *) {
            btn.setImage(UIImage(systemName: systemIcon), for: .normal)
        }
        btn.tintColor = tint
        btn.backgroundColor = pillBG
        btn.layer.cornerRadius = 18
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
        // Show-to chip (NURSE_REMARKS_SHOW_D_N_ROW)
        showToButton.setTitle("Show to: \(presenter.draftShowToLabel)", for: .normal)

        // Priority chip (NURSE_REMARKS_PRIORITY_ROW)
        priorityButton.setTitle(presenter.draftPriorityLabel, for: .normal)
        let isUrgent = presenter.isUrgentPriority
        priorityButton.backgroundColor = isUrgent ? urgent.withAlphaComponent(0.12) : pillBG
        priorityButton.setTitleColor(isUrgent ? urgent : UIColor(white: 0.25, alpha: 1), for: .normal)
        priorityButton.tintColor = isUrgent ? urgent : teal
    }

    /// Updates the filter pill to show the current active filter state.
    private func updateFilterPill() {
        let vt = presenter.activeVisitTypeLabel
        let f  = presenter.activeFilterLabel
        let hasFilter = (presenter.activeVisitTypeId != "" || presenter.activeFilterId != "")
        if hasFilter {
            filterPill.setTitle("\(vt) • \(f)", for: .normal)
            filterPill.backgroundColor = teal.withAlphaComponent(0.12)
            filterPill.setTitleColor(teal, for: .normal)
        } else {
            filterPill.setTitle("Filter", for: .normal)
            filterPill.backgroundColor = pillBG
            filterPill.setTitleColor(UIColor(white: 0.25, alpha: 1), for: .normal)
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
        sheet.visitTypeOptions  = presenter.visitTypes
        sheet.filterOptions     = presenter.filters
        sheet.initialVisitTypeId = presenter.activeVisitTypeId
        sheet.initialFilterId    = presenter.activeFilterId
        sheet.delegate = self
        present(sheet, animated: false)
    }

    /// Show-to uses NURSE_REMARKS_SHOW_D_N_ROW — sets who can see the note being composed.
    @objc private func didTapShowTo() {
        let list = presenter.showToList   // NURSE_REMARKS_SHOW_D_N_ROW
        guard !list.isEmpty else {
            showToButton.setTitle("Show to: All", for: .normal); return
        }
        let ac = UIAlertController(title: "Show to", message: nil, preferredStyle: .actionSheet)
        for item in list {
            ac.addAction(UIAlertAction(title: item.label, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presenter.draftShowToId = item.id
                self.updateComposerChips()
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.sourceView = view
        ac.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 1, height: 1)
        present(ac, animated: true)
    }

    /// Priority uses NURSE_REMARKS_PRIORITY_ROW — sets the priority of the note being composed.
    @objc private func didTapPriority() {
        let list = presenter.priorities   // NURSE_REMARKS_PRIORITY_ROW
        let ac = UIAlertController(title: "Priority", message: nil, preferredStyle: .actionSheet)
        if list.isEmpty {
            // Fallback if server didn't return lookup rows yet.
            for (id, label) in [("1", "Normal"), ("3", "Urgent")] {
                ac.addAction(UIAlertAction(title: label, style: .default) { [weak self] _ in
                    self?.presenter.draftPriorityId = id
                    self?.updateComposerChips()
                })
            }
        } else {
            for item in list {
                ac.addAction(UIAlertAction(title: item.label, style: .default) { [weak self] _ in
                    self?.presenter.draftPriorityId = item.id
                    self?.updateComposerChips()
                })
            }
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.sourceView = view
        ac.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 1, height: 1)
        present(ac, animated: true)
    }

    @objc private func textChanged() {
        presenter.draftText = textField.text ?? ""
    }

    @objc private func didTapSend() {
        view.endEditing(true)
        presenter.draftText = textField.text ?? ""
        presenter.send()
    }

    @objc private func didTapMic() {
        if recorder.isRecording {
            _ = recorder.stopRecording()
            recordingLabel.isHidden = false
            recordingLabel.text = "● Voice note ready"
            presenter.draftVoiceURL = recorder.recordedURL
            if #available(iOS 13, *) {
                micButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            }
            return
        }
        if recorder.isPlaying {
            recorder.stopPlayback()
            if #available(iOS 13, *) {
                micButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            }
            return
        }
        if recorder.recordedURL != nil {
            // Play back the recorded note.
            _ = recorder.startPlayback()
            if #available(iOS 13, *) {
                micButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            }
            return
        }
        requestMicPermission { [weak self] granted in
            guard let self = self, granted else {
                self?.presentAlert("Microphone access is required to record voice notes.")
                return
            }
            if self.recorder.startRecording() {
                self.recordingLabel.isHidden = false
                self.recordingLabel.text = "● Recording…"
                if #available(iOS 13, *) {
                    self.micButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                }
            } else {
                self.presentAlert("Could not start recording.")
            }
        }
    }

    // MARK: - Helpers

    private func presentActionSheet(title: String,
                                    options: [String],
                                    onPick: @escaping (Int, String) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for (i, opt) in options.enumerated() {
            ac.addAction(UIAlertAction(title: opt, style: .default) { _ in
                onPick(i, opt)
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad popover safety
        ac.popoverPresentationController?.sourceView = view
        ac.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 1, height: 1)
        present(ac, animated: true)
    }

    private func presentAlert(_ msg: String) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    private func requestMicPermission(_ completion: @escaping (Bool) -> Void) {
        // Older SDKs expose `recordPermission()` as a method returning
        // `AVAudioSessionRecordPermission`. The compile-time constants are
        // `AVAudioSessionRecordPermission.granted`, `.denied`, `.undetermined`.
        let session = AVAudioSession.sharedInstance()
        let status: AVAudioSessionRecordPermission = session.recordPermission()
        switch status {
        case AVAudioSessionRecordPermission.granted: completion(true)
        case AVAudioSessionRecordPermission.denied:  completion(false)
        case AVAudioSessionRecordPermission.undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default: completion(false)
        }
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
        return presenter?.notes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProgressNoteRowCell.reuseId,
                                                 for: indexPath) as! ProgressNoteRowCell
        cell.configure(with: presenter.notes[indexPath.row])
        return cell
    }
}

// MARK: - ProgressNotesView

extension ProgressNotesViewController: ProgressNotesView {
    func progressNotesDidReload() {
        emptyLabel.isHidden = !presenter.notes.isEmpty
        tableView.reloadData()
        updateComposerChips()
        updateFilterPill()
    }

    func progressNotesDidSend(success: Bool, message: String?) {
        textField.text = ""
        recordingLabel.isHidden = true
        recordingLabel.text = ""
        if #available(iOS 13, *) {
            micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
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

// MARK: - VoiceNoteRecorderDelegate

extension ProgressNotesViewController: VoiceNoteRecorderDelegate {
    func voiceNoteRecorder(_ recorder: VoiceNoteRecorder, didUpdateLevel level: Float) {
        // Cheap "pulse" effect on the mic button while recording.
        let scale: CGFloat = 1.0 + CGFloat(level) * 0.15
        UIView.animate(withDuration: 0.08) {
            self.micButton.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    func voiceNoteRecorderDidFinishPlaying(_ recorder: VoiceNoteRecorder) {
        if #available(iOS 13, *) {
            micButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
    }
}
