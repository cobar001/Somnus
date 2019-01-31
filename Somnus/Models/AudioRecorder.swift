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
	
	public func printRecorderChannels() {
		if mAudioRecorder != nil {
			print("channels: \(String(describing: mAudioRecorder.channelAssignments))")
		}
	}
	
	public func requestRecordAuthorization() {
		if mRecordingSession.recordPermission != .granted {
			mRecordingSession.requestRecordPermission() { allowed in
				DispatchQueue.main.async {
					if allowed {
						print("recording permission authorized")
					} else {
						print("recording permission not authorized")
					}
				}
			}
		}
	}
	
	public func initRecorder(filename: String) {
		do {
			try mRecordingSession.setCategory(.playAndRecord, mode: .default)
			try mRecordingSession.setActive(true)
		} catch {
			print("error initializing recorder")
		}
		let audioFilename = SomnusUtils.shared.getDocumentsDirectory().appendingPathComponent("\(filename).m4a")
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 8000,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
		]
		do {
			mAudioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			mAudioRecorder.delegate = self
			
		} catch {
			stopRecording()
		}
	}
	
	public func startRecording(timeOffset: TimeInterval?) {
		if let time: TimeInterval = timeOffset {
			mAudioRecorder.record(atTime: time)
		} else {
			mAudioRecorder.record()
		}
		print("recording started")
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
		print("finished recording delegate")
	}
}
