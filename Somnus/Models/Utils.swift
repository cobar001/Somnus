//
//  Utils.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications
import AVFoundation
import Speech

	/***
	* Utility Properties
	*/

// App-wide constants
let FONTNAME: String = "Avenir-Roman"
let FONTNAMEBOLD: String = "Avenir-Heavy"

let SCREENBOUNDS: CGRect = UIScreen.main.bounds

let PURPLECOLOR: UIColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1.0)
let ORANGECOLOR: UIColor = UIColor(red: 249/255, green: 105/255, blue: 14/255, alpha: 1.0)
let SUNCOLOR: UIColor = UIColor(red: 238/255, green: 238/255, blue: 0, alpha: 1.0)
let SUNRAYCOLOR: UIColor = UIColor(red: 247/255, green: 202/255, blue: 24/255, alpha: 1.0)

	/***
	* Utility Classes
	*/

// Singleton utility class
class SomnusUtils {
	
	// TODO: Modularize this class into seperate discretized classes
	// where applicable (audio, etc.)
	
	static let shared = SomnusUtils()
	
	init() {
		print("Somnus Utils init")
		
		// Music Player init
		kMPMediaPlayer.repeatMode = MPMusicRepeatMode.all
		kMPMediaPlayer.shuffleMode = MPMusicShuffleMode.off
		
		// Utils init
		print("screen: \(UIScreen.main.bounds)")
		if SCREENBOUNDS.height <= 700 {
			kHasSmallerScreen = true
			print("has smaller screen: \(kHasSmallerScreen)")
		}
	}
	
	// Media Player Tools
	
	public let kMPMediaPlayer: MPMusicPlayerApplicationController =
		MPMusicPlayerApplicationController.applicationQueuePlayer
	public var mMPMediaPlaylists: Array<MPMediaPlaylist> = Array<MPMediaPlaylist>()
	public var mCurrentVolume: Float = 0.5

	public func startPlaylistContinuous(selectedPlaylist: MPMediaPlaylist?) {
		guard let playlist: MPMediaPlaylist = selectedPlaylist else {
			print("selectedPlaylist nil")
			return
		}
		kMPMediaPlayer.setQueue(with: playlist)
		kMPMediaPlayer.play()
		kMPMediaPlayer.beginGeneratingPlaybackNotifications()
	}
	
	public func stopPlaylist() {
		print("stop playing playlist")
		kMPMediaPlayer.stop()
		kMPMediaPlayer.endGeneratingPlaybackNotifications()
	}
	
	public func checkMediaLibraryPermissions() -> Bool {
		// Check media player permissions
		var permissionGranted: Bool = false
		let mediaLibraryAuthorizationStatus: MPMediaLibraryAuthorizationStatus =
			MPMediaLibrary.authorizationStatus()
		if mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.denied ||
			mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.restricted ||
			mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.notDetermined {
			print("media player access denied, restricted, or not determined")
		} else if mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.authorized {
			print("media player access authorized")
			permissionGranted = true
		} else {
			print("media player access failed")
		}
		return permissionGranted
	}
	
	// Utils
	
	public var kHasSmallerScreen: Bool = false
	
	public func generateRandomPositionWithBounds(
		widthBounds: Array<Int>, heightBounds: Array<Int>) throws -> CGPoint {
		if widthBounds.count != 2 || heightBounds.count != 2 {
			throw InputError.InvalidInput
		}
		let randomX: Int = Int.random(in: widthBounds[0]..<widthBounds[1])
		let randomY: Int = Int.random(in: heightBounds[0]..<heightBounds[1])
		let randomPoint: CGPoint = CGPoint(x: randomX, y: randomY)
		return randomPoint
	}
	
	public func formatSeconds(seconds: Double) -> String {
		let interval: Int = Int(seconds)
		let seconds: Int = interval % 60
		let minutes: Int = (interval / 60) % 60
		let hours: Int = (interval / 3600)
		return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
	}
	
	public func formatDate(date: Date, calendar: Calendar) -> String {
		let components: DateComponents =
			calendar.dateComponents([.hour, .minute], from: date)
		var hour: Int = components.hour!
		let minute: Int = components.minute!
		var suffix: String = "AM"
		if hour == 0 {
			suffix = "AM"; hour = 12;
		} else if hour > 12 {
			suffix = "PM"; hour -= 12;
		} else if hour == 12 {
			suffix = "PM"; hour = 12;
		}
		return String(format: "%02d:%02d %@", hour, minute, suffix)
	}
	
	public func getCorrectDate(date: Date, calendar: Calendar) -> Date {
		if date < Date() {
			print("earlier date, set for tomorrow at this time")
			if let datePlusDay: Date = calendar.date(byAdding: .day, value: 1, to: date) {
				return datePlusDay
			} else {
				print("error correcting date")
				return date
			}
		} else {
			print("later date, set for later today at this time")
			return date
		}
	}
	
	// Notification Tools
	
	public func requestNotificationCenterAuthorization() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
			(granted, error) in
			if !granted {
				print("notification permission not granted")
			} else {
				print("notification permission granted")
			}
		}
	}
	
	public func checkNotificationCenterPermissions() -> Bool {
		let notificationType =
			UIApplication.shared.currentUserNotificationSettings?.types
		guard let isTypeEmpty: Bool = notificationType?.isEmpty else {
			return false
		}
		return !isTypeEmpty
	}
	
	// Speech recognition tools
	
	let kAudioEngine: AVAudioEngine = AVAudioEngine()
	let kSpeechRecognizer: SFSpeechRecognizer =
		SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
	var mSpeechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	var mSpeechRecognitionTask: SFSpeechRecognitionTask?
	var mIsSpeechRecognitionActive: Bool = false
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
	
	public func startSpeechRecognition() throws {
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
				self.kAudioEngine.stop()
				inputNode.removeTap(onBus: 0)
				self.mSpeechRecognitionRequest = nil
				self.mSpeechRecognitionTask = nil
				self.mIsSpeechRecognitionActive = false
			}
		}
		// Configure the microphone input.
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
			(buffer: AVAudioPCMBuffer, when: AVAudioTime) in
			self.mSpeechRecognitionRequest?.append(buffer)
		}
		// Start the engine
		kAudioEngine.prepare()
		try kAudioEngine.start()
		
		// Let the user know to start talking.
		print("(Go ahead, I'm listening)")
		mIsSpeechRecognitionActive = true
	}
	
	public func stopSpeechRecognition() {
		print("stop speech recognition")
		kAudioEngine.stop()
		kAudioEngine.inputNode.removeTap(onBus: 0)
		mSpeechRecognitionTask?.cancel()
		mIsSpeechRecognitionActive = false
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
}

	/***
	* Error & Util Types
	*/

enum InputError: Error {
	case InvalidInput
	case NotEnoughInputParameters
	case InvalidInputType
}

enum PlaylistError: Error {
	case EmptyCountdownPlaylist
	case EmptyAlarmPlaylist
	case CountdownPlaylistNotChosen
	case AlarmPlaylistNotChosen
}

enum PermissionsError: Error {
	case MissingMediaPermissions
	case MissingNotificationsPermissions
}

enum SpeechRecognitionResult {
	case none, stop, snooze
}
	/***
	* Extensions
	*/

extension UICollectionView {
	
	func setEmptyMessage(_ message: String) {
		let messageLabel = UILabel(
			frame: CGRect(x: 0, y: 0,
						  width: self.bounds.size.width,
						  height: self.bounds.size.height))
		messageLabel.text = message
		messageLabel.textColor = .black
		messageLabel.numberOfLines = 0;
		messageLabel.textAlignment = .center;
		messageLabel.font = UIFont(name: FONTNAME, size: 18)
		messageLabel.sizeToFit()
		
		self.backgroundView = messageLabel;
	}
	
	func restore() {
		self.backgroundView = nil
	}
}

extension Date {
	var localizedDescription: String {
		return description(with: .current)
	}
}
