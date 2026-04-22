//
//  VoiceNoteRecorder.swift
//  DoctorDesktop
//
//  Thin AVAudioRecorder/AVAudioPlayer wrapper for the progress-notes composer.
//  Records to an `.m4a` file in the caches directory and exposes the recorded
//  file URL so the presenter can base64-encode it or upload it once the server
//  contract for voice notes is finalised.
//
//  The host VC is responsible for requesting microphone permission — this
//  helper only starts recording/playback once permission has been granted.
//

import Foundation
import AVFoundation

protocol VoiceNoteRecorderDelegate: AnyObject {
    /// Fires every 0.1s while recording, giving UI a chance to animate a level meter.
    func voiceNoteRecorder(_ recorder: VoiceNoteRecorder, didUpdateLevel level: Float)
    /// Fires when playback reaches the end of the recorded file.
    func voiceNoteRecorderDidFinishPlaying(_ recorder: VoiceNoteRecorder)
}

final class VoiceNoteRecorder: NSObject {

    weak var delegate: VoiceNoteRecorderDelegate?

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var levelTimer: Timer?

    /// URL of the most recently completed recording (nil before the first stop).
    private(set) var recordedURL: URL?

    var isRecording: Bool { return recorder?.isRecording ?? false }
    var isPlaying:   Bool { return player?.isPlaying   ?? false }

    /// Duration (seconds) of the last recording, or 0 if nothing is recorded.
    var recordedDuration: TimeInterval {
        guard let url = recordedURL else { return 0 }
        return (try? AVAudioPlayer(contentsOf: url).duration) ?? 0
    }

    // MARK: - Recording

    /// Starts a new recording. Overwrites the previous file. Returns false if
    /// the AVAudioSession/recorder failed to start.
    @discardableResult
    func startRecording() -> Bool {
        stopPlayback()

        let session = AVAudioSession.sharedInstance()
        do {
            // Older SDKs expose setCategory as a String-based API; constants are
            // AVAudioSessionCategoryPlayAndRecord and AVAudioSessionCategoryOptions.
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord,
                                    with: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return false
        }

        let fileName = "progress_note_\(Int(Date().timeIntervalSince1970)).m4a"
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let url = cachesDir.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey:             Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:           44100.0,
            AVNumberOfChannelsKey:     1,
            AVEncoderAudioQualityKey:  AVAudioQuality.medium.rawValue
        ]

        do {
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.isMeteringEnabled = true
            rec.delegate = self
            if !rec.record() { return false }
            self.recorder    = rec
            self.recordedURL = url
            startLevelTimer()
            return true
        } catch {
            return false
        }
    }

    /// Stops recording and returns the file URL (or nil if nothing was captured).
    @discardableResult
    func stopRecording() -> URL? {
        stopLevelTimer()
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        return recordedURL
    }

    /// Discards the most recent recording and its file.
    func discardRecording() {
        stopRecording()
        if let url = recordedURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordedURL = nil
    }

    // MARK: - Playback

    @discardableResult
    func startPlayback() -> Bool {
        guard let url = recordedURL else { return false }
        stopRecording()

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            if !p.play() { return false }
            self.player = p
            return true
        } catch {
            return false
        }
    }

    func stopPlayback() {
        player?.stop()
        player = nil
    }

    // MARK: - Level metering

    private func startLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let rec = self.recorder else { return }
            rec.updateMeters()
            // Convert dBFS (-160…0) to 0…1 roughly.
            let db = rec.averagePower(forChannel: 0)
            let level = max(0, min(1, (db + 60) / 60))
            self.delegate?.voiceNoteRecorder(self, didUpdateLevel: level)
        }
    }

    private func stopLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
}

// MARK: - AVAudioRecorderDelegate / AVAudioPlayerDelegate

extension VoiceNoteRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopLevelTimer()
    }
}

extension VoiceNoteRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.voiceNoteRecorderDidFinishPlaying(self)
        self.player = nil
    }
}
