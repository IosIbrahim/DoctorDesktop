//
//  ReplyComposerViewController.swift
//  DoctorDesktop
//
//  Modal "Reply" composer used by ProgressNotesViewController.
//
//  Why a custom modal instead of UIAlertController?
//    UIAlertController doesn't let us host a mic button or a multi-line text
//    view — and the user wants live speech-to-text inside the reply flow,
//    same as the main composer. So this is a small dimmed-overlay sheet with:
//        • Title
//        • Multi-line UITextView
//        • Mic button (toggles SpeechDictation; stop icon while listening)
//        • Cancel / Send buttons
//
//  Owns its own SpeechDictation instance so it can run in parallel with the
//  parent screen's dictation without state collisions.
//

import UIKit
import AVFoundation

final class ReplyComposerViewController: UIViewController {

    // MARK: - Output

    /// Called with the trimmed reply text when the user taps Send.
    /// `nil` means the user cancelled.
    var onSubmit: ((String?) -> Void)?

    // MARK: - Theme (mirrors ProgressNotesViewController)

    private let teal       = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
    private let pillBG     = UIColor(red: 0.94, green: 0.97, blue: 0.96, alpha: 1)
    private let pillBorder = UIColor(red: 0.86, green: 0.91, blue: 0.90, alpha: 1)
    private let urgent     = UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1)

    // MARK: - Subviews

    private let dimmer    = UIView()
    private let card      = UIView()
    private let titleLbl  = UILabel()
    private let textView  = UITextView()
    private let placeholder = UILabel()
    private let recordingLbl = UILabel()
    private let micButton    = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let sendButton   = UIButton(type: .system)

    // MARK: - State

    private let dictation = SpeechDictation()
    /// Snapshot of the text that was in the field before dictation started,
    /// so partial transcripts are appended (not overwriting manual edits).
    private var preDictationText: String = ""
    private var cardBottomConstraint: NSLayoutConstraint!

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle   = .crossDissolve
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        dictation.delegate = self
        buildUI()
        registerKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    deinit {
        dictation.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Build UI

    private func buildUI() {

        // ── Dim background ──────────────────────────────────────────────────
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDimmer))
        dimmer.addGestureRecognizer(tap)

        // ── Card ────────────────────────────────────────────────────────────
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor   = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowRadius  = 12
        card.layer.shadowOffset  = CGSize(width: 0, height: 4)
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        // ── Title ───────────────────────────────────────────────────────────
        titleLbl.text = "Reply"
        titleLbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = UIColor(white: 0.12, alpha: 1)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLbl)

        // ── Text view (multi-line) ──────────────────────────────────────────
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = UIColor(white: 0.15, alpha: 1)
        textView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1)
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth  = 1
        textView.layer.borderColor  = pillBorder.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.autocapitalizationType = .sentences
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(textView)

        // Placeholder (UITextView has no native placeholder).
        placeholder.text = "Write a reply…"
        placeholder.font = UIFont.systemFont(ofSize: 15)
        placeholder.textColor = UIColor(white: 0.62, alpha: 1)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(placeholder)

        // ── Recording label (visible while dictation is live) ──────────────
        recordingLbl.text = "● Listening…"
        recordingLbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        recordingLbl.textColor = urgent
        recordingLbl.isHidden = true
        recordingLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(recordingLbl)

        // ── Mic button ──────────────────────────────────────────────────────
        styleIconButton(micButton, systemIcon: "mic.fill", tint: teal)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.addTarget(self, action: #selector(didTapMic), for: .touchUpInside)
        card.addSubview(micButton)

        // ── Cancel / Send ───────────────────────────────────────────────────
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cancelButton.setTitleColor(UIColor(white: 0.45, alpha: 1), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        card.addSubview(cancelButton)

        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = teal
        sendButton.layer.cornerRadius = 16
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        card.addSubview(sendButton)

        // ── Layout ──────────────────────────────────────────────────────────
        cardBottomConstraint = card.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -40)

        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: view.topAnchor),
            dimmer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardBottomConstraint,

            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            textView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100),

            placeholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 14),

            recordingLbl.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 6),
            recordingLbl.leadingAnchor.constraint(equalTo: textView.leadingAnchor),

            micButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            micButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            micButton.widthAnchor.constraint(equalToConstant: 36),
            micButton.heightAnchor.constraint(equalToConstant: 36),
            micButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            sendButton.centerYAnchor.constraint(equalTo: micButton.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 32),

            cancelButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
        ])
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

    // MARK: - Actions

    @objc private func didTapDimmer() {
        // Tapping outside the card cancels — same affordance as a UIAlertController.
        didTapCancel()
    }

    @objc private func didTapCancel() {
        dictation.cancel()
        onSubmit?(nil)
        dismiss(animated: true)
    }

    @objc private func didTapSend() {
        let trimmed = (textView.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        dictation.cancel()
        onSubmit?(trimmed)
        dismiss(animated: true)
    }

    @objc private func didTapMic() {
        if dictation.isRunning {
            dictation.stop()
            showDictationIdleState()
            return
        }
        preDictationText = textView.text ?? ""
        dictation.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.presentAlert("Microphone and Speech Recognition access are required to dictate. Enable them in Settings.")
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

    private func showDictationRunningState() {
        recordingLbl.isHidden = false
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            micButton.setImage(UIImage(systemName: "stop.fill", withConfiguration: cfg),
                               for: .normal)
            micButton.tintColor = urgent
            micButton.layer.borderColor = urgent.withAlphaComponent(0.35).cgColor
        }
    }

    private func showDictationIdleState() {
        recordingLbl.isHidden = true
        if #available(iOS 13, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            micButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: cfg),
                               for: .normal)
            micButton.tintColor = teal
            micButton.layer.borderColor = pillBorder.cgColor
        }
    }

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
        // Pin the card above the keyboard with a small breathing gap.
        cardBottomConstraint.constant = -overlap - 12
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    @objc private func kbWillHide(_ note: Notification) {
        cardBottomConstraint.constant = -40
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

// MARK: - UITextViewDelegate

extension ReplyComposerViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - SpeechDictationDelegate

extension ReplyComposerViewController: SpeechDictationDelegate {

    func speechDictation(_ dictation: SpeechDictation,
                         didUpdateTranscription text: String,
                         isFinal: Bool) {
        let joiner: String
        if preDictationText.isEmpty {
            joiner = ""
        } else if preDictationText.hasSuffix(" ") || preDictationText.hasSuffix("\n") {
            joiner = ""
        } else {
            joiner = " "
        }
        let merged = preDictationText + joiner + text
        textView.text = merged
        placeholder.isHidden = !merged.isEmpty

        if isFinal {
            showDictationIdleState()
            preDictationText = merged
        }
    }

    func speechDictation(_ dictation: SpeechDictation, didFailWith message: String) {
        showDictationIdleState()
        presentAlert("Speech recognition failed: \(message)")
    }
}
