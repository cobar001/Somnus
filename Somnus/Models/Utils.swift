//
//  Utils.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit
import UserNotifications

// App-wide constants
let FONTNAME: String = "Avenir-Roman"
let FONTNAMEBOLD: String = "Avenir-Heavy"

let SCREENBOUNDS: CGRect = UIScreen.main.bounds

let PURPLECOLOR: UIColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1.0)
let ORANGECOLOR: UIColor = UIColor(red: 249/255, green: 105/255, blue: 14/255, alpha: 1.0)
let SUNCOLOR: UIColor = UIColor(red: 238/255, green: 238/255, blue: 0, alpha: 1.0)
let SUNRAYCOLOR: UIColor = UIColor(red: 247/255, green: 202/255, blue: 24/255, alpha: 1.0)

// Singleton utility class
class SomnusUtils {
	
	static let shared = SomnusUtils()
	
	init() {
		print("Somnus Utils init")
		// Utils init
		print("screen: \(UIScreen.main.bounds)")
		if SCREENBOUNDS.height <= 700 {
			kHasSmallerScreen = true
			print("has smaller screen: \(kHasSmallerScreen)")
		}
	}
	
	// Utils
	
	public var mSomnusSessionState: SomnusSessionState = .inactive
	private var kHasSmallerScreen: Bool = false
	private let kImpactFeedbackGenerator: UIImpactFeedbackGenerator
		= UIImpactFeedbackGenerator(style: .heavy)
	
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
	
	public func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	public func removeFilesFromDirectory(url: URL) {
		do {
			let fileURLs = try FileManager.default.contentsOfDirectory(
				at: url, includingPropertiesForKeys: nil,
				options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
			for fileURL in fileURLs {
				try FileManager.default.removeItem(at: fileURL)
			}
		} catch  { print("Error removing files: \(error)") }
	}
	
	public func vibrate() {
		kImpactFeedbackGenerator.impactOccurred()
	}
	
	public func hasSmallerScreen() -> Bool {
		return kHasSmallerScreen
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

	public func pushNotification(title: String, body: String) {
		SomnusUtils.shared.vibrate()
		if SomnusUtils.shared.checkNotificationCenterPermissions() {
			let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
			notificationContent.title = title
			notificationContent.body = body
			let trigger: UNTimeIntervalNotificationTrigger =
				UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
			let request: UNNotificationRequest = UNNotificationRequest(
				identifier: "SomnusLocalNotification", content: notificationContent, trigger: trigger)
			UNUserNotificationCenter.current().add(request) { (error) in
				if let error = error {
					print("Error: \(error.localizedDescription)")
				}
			}
		}
	}
}

enum SomnusSessionState {
	case active, inactive, alarmWake, snoozed
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
