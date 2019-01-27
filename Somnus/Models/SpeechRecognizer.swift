//
//  SpeechRecognizer.swift
//  Somnus
//
//  Created by Chris Cobar on 1/27/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizer {
	
	static let shared = SpeechRecognizer()
	
	init() {
		print("speech recognizer init")
	}
	
	let kAudioEngine: AVAudioEngine = AVAudioEngine()
	let kSpeechRecognizer: SFSpeechRecognizer =
		SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
	var mSpeechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	var mSpeechRecognitionTask: SFSpeechRecognitionTask?
	var mCurrentSpeechRecognitionResult: SpeechRecognitionResult = .none
	
	public func requestSpeechRecognitionAuthorization() {
		SFSpeechRecognizer.requestAuthorization { (authStatus) in
			switch authStatus {
			case .authorized:
				print("Sppech recognition authorized")
			case .denied:
				print("Speech recognition authorization denied")
			case .restricted:
				print("Not available on this device")
			case .notDetermined:
				print("Not determined")
			}
		}
	}
	
	public func checkSpeechRecognitionAuthorization() -> Bool {
		return (SFSpeechRecognizer.authorizationStatus() ==
			SFSpeechRecognizerAuthorizationStatus.authorized)
	}
	
	public func requestRecordingAuthorization() {
		AVAudioSession.sharedInstance().requestRecordPermission { (result) in
			if result {
				print("recording authorization granted")
			} else {
				print("recording authorization denied")
			}
		}
	}
	
	public func checkRecordingAuthorization() -> Bool {
		return (AVAudioSession.sharedInstance().recordPermission ==
			AVAudioSession.RecordPermission.granted)
	}
	
	public func startSpeechRecognition() throws {
		if kAudioEngine.isRunning {
			return
		}
		let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
		try audioSession.setCategory(
			.playAndRecord, mode: .measurement, options: [.mixWithOthers,
														  .allowBluetooth,
														  .allowBluetoothA2DP,
														  .defaultToSpeaker]) // check these
		try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
		let inputNode = kAudioEngine.inputNode
		
		// Setup audio engine and speech recognizer
		mSpeechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		if mSpeechRecognitionRequest == nil {
			print("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
			return
		}
		mSpeechRecognitionRequest!.shouldReportPartialResults = true
		
		// Create a recognition task for the speech recognition session.
		// Keep a reference to the task so that it can be canceled.
		mSpeechRecognitionTask = kSpeechRecognizer.recognitionTask(with: mSpeechRecognitionRequest!) {
			[unowned self] result, error in
			if let result = result {
				print("transcript: \(result.bestTranscription.formattedString)")
				self.processSpeechTranscript(
					transcript: result.bestTranscription.formattedString)
				if result.isFinal {
					print("SPEECH RECOGNITION FINAL")
					self.stopSpeechRecognition()
				}
			}
			if error != nil {
				// Stop recognizing speech if there is a problem.
				print("error in recognition task")
				self.stopSpeechRecognition()
			}
		}
		// Configure the microphone input.
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) {
			(buffer: AVAudioPCMBuffer, when: AVAudioTime) in
			self.mSpeechRecognitionRequest?.append(buffer)
		}
		// Start the engine
		kAudioEngine.prepare()
		try kAudioEngine.start()
		
		// Let the user know to start talking.
		print("(Go ahead, I'm listening)")
	}
	
	public func stopSpeechRecognition() {
		print("stop speech recognition")
		if kAudioEngine.isRunning {
			kAudioEngine.stop()
			kAudioEngine.inputNode.removeTap(onBus: 0)
			mSpeechRecognitionTask?.cancel()
			mSpeechRecognitionRequest = nil
		}
	}
	
	public func processSpeechTranscript(transcript: String) {
		let stop: String = "stop"
		let snooze: String = "snooze"
		let prepTranscript: String = transcript.lowercased()
		if prepTranscript.contains(snooze) &&
			mCurrentSpeechRecognitionResult != SpeechRecognitionResult.snooze {
			print("snooze")
			mCurrentSpeechRecognitionResult = .snooze
		} else if prepTranscript.contains(stop) {
			print("stop")
			mCurrentSpeechRecognitionResult = .stop
		} else {
			print("none")
			mCurrentSpeechRecognitionResult = .none
		}
	}
	
	public func resetSpeechRecognitionResult() {
		mCurrentSpeechRecognitionResult = .none
	}
	
	public func getSpeechRecognitionResult() -> SpeechRecognitionResult {
		return mCurrentSpeechRecognitionResult
	}
	
	public func speechRecognitionIsRunning() -> Bool {
		return kAudioEngine.isRunning
	}
}

enum SpeechRecognitionResult {
	case none, stop, snooze
}
