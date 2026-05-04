//
//  SpeechDictation.swift
//  DoctorDesktop
//
//  Thin wrapper around SFSpeechRecognizer + AVAudioEngine for live speech-to-text.
//
//  Flow:
//    • Call `requestAuthorization(_:)` once to prompt the user for Speech +
//      Microphone permissions.
//    • Call `start()` → delegate receives `didUpdateTranscription(_:isFinal:)`
//      as the user speaks.
//    • Call `stop()` → the final transcription is delivered with isFinal=true
//      and the audio engine is torn down.
//
//  Locale: defaults to the device preferred language; can be overridden via
//  `init(locale:)`. Typical production use is en-US; pass Locale(identifier: "ar-SA")
//  for Arabic dictation.
//

import Foundation
import Speech
import AVFoundation

// MARK: - Delegate

protocol SpeechDictationDelegate: AnyObject {
    /// Called on the main queue whenever a new partial / final transcription arrives.
    /// `isFinal == true` means the recognizer finished processing this utterance.
    func speechDictation(_ dictation: SpeechDictation,
                         didUpdateTranscription text: String,
                         isFinal: Bool)
    /// Called on the main queue if authorization is denied or the recognizer fails.
    func speechDictation(_ dictation: SpeechDictation, didFailWith message: String)
}

// MARK: - Dictation

final class SpeechDictation {

    weak var delegate: SpeechDictationDelegate?

    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task:    SFSpeechRecognitionTask?

    /// True while audio is being captured and streamed to the recognizer.
    private(set) var isRunning: Bool = false

    init(locale: Locale = Locale.current) {
        // Fall back to en-US if the preferred locale isn't supported.
        self.recognizer = SFSpeechRecognizer(locale: locale)
            ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    // MARK: - Permissions

    /// Requests Speech + Microphone authorization in sequence. Completion is
    /// called on the main queue with `true` only if BOTH are granted.
    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            let speechOK = (speechStatus == .authorized)
            AVAudioSession.sharedInstance().requestRecordPermission { micOK in
                DispatchQueue.main.async {
                    completion(speechOK && micOK)
                }
            }
        }
    }

    // MARK: - Start / Stop

    /// Starts a new recognition session. Any previous session is cancelled.
    /// Safe to call from the main queue.
    func start() {
        guard !isRunning else { return }
        guard let recognizer = recognizer, recognizer.isAvailable else {
            delegate?.speechDictation(self,
                                      didFailWith: "Speech recognition is not available.")
            return
        }

        // Tear down any lingering state (idempotent).
        cancelInternal()

        // Configure the audio session for recording.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord,
                                    with: [.duckOthers])
            try session.setMode(AVAudioSessionModeMeasurement)
            try session.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            delegate?.speechDictation(self,
                                      didFailWith: "Could not start audio session.")
            return
        }

        // Build the recognition request.
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        self.request = req

        // Install a tap on the mic input and pipe buffers into the request.
        let inputNode = audioEngine.inputNode
        let format    = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.speechDictation(self,
                                      didFailWith: "Could not start audio engine.")
            cancelInternal()
            return
        }

        // Kick off the recognition task.
        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.delegate?.speechDictation(self,
                                                   didUpdateTranscription: text,
                                                   isFinal: result.isFinal)
                }
                if result.isFinal { self.cancelInternal() }
            }
            if let error = error {
                // Silent no-op for normal-flow "errors" — these fire when the
                // recognizer is stopped mid-session (e.g. user taps Send before
                // tapping Stop) or when no speech is detected. Treat as success.
                //   1110 — "No speech detected"
                //    216 — kAFAssistantErrorDomain "operation cancelled"
                //    203 — "Recognition Request Was Canceled"
                //   1101 — "Connection invalidated"
                let code = (error as NSError).code
                let silent: Set<Int> = [1110, 216, 203, 1101]
                if !silent.contains(code) {
                    DispatchQueue.main.async {
                        self.delegate?.speechDictation(self,
                                                       didFailWith: error.localizedDescription)
                    }
                }
                self.cancelInternal()
            }
        }

        isRunning = true
    }

    /// Stops the recognition session. The recognizer will emit a final result
    /// via the delegate shortly after, once it has processed buffered audio.
    func stop() {
        guard isRunning else { return }
        request?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRunning = false
        // Leave `task` alive so the final-result callback can still fire.
    }

    /// Hard-cancels any active session (no final callback).
    func cancel() {
        cancelInternal()
    }

    // MARK: - Internal

    private func cancelInternal() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.cancel()
        request = nil
        task    = nil
        isRunning = false
    }
}
