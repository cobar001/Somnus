//
//  AudioRecorder.swift
//  Somnus
//
//  Created by Chris Cobar on 1/27/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
	
	static let shared = AudioRecorder()
	
	override init() {
		print("audio recorder init")
	}
	
	private let mRecordingSession: AVAudioSession = AVAudioSession.sharedInstance()
	private var mAudioRecorder: AVAudioRecorder!
	
	public func initAndRequestRecorderAuthorization() {
		do {
			try mRecordingSession.setCategory(.playAndRecord, mode: .default)
			try mRecordingSession.setActive(true)
			mRecordingSession.requestRecordPermission() { allowed in
				DispatchQueue.main.async {
					if allowed {
						print("recording permission authorized")
					} else {
						print("recording permission not authorized")
					}
				}
			}
		} catch {
			print("error requesting Record authorization and initialization")
		}
	}
	
	public func startRecording(filename: String) {
		let audioFilename = SomnusUtils.shared.getDocumentsDirectory().appendingPathComponent("\(filename).m4a")
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		do {
			mAudioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			mAudioRecorder.delegate = self
			mAudioRecorder.record()
			print("recording started")
		} catch {
			stopRecording()
		}
	}
	
	public func stopRecording() {
		if mAudioRecorder != nil {
			mAudioRecorder.stop()
			mAudioRecorder = nil
			print("recording stopped")
		}
	}
	
	public func audioRecorderIsrecording() -> Bool {
		if mAudioRecorder == nil || !mAudioRecorder.isRecording {
			return false
		}
		return true
	}
	
	// Audio Recorder Delegate
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if !flag {
			print("recording failed (delegate)")
			stopRecording()
		}
	}
}
