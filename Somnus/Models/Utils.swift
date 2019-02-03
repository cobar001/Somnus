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
let GRAYCOLOR: UIColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 0.25)
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
	
	public func getFilesInDocumentsDirectory() -> Array<URL>? {
		var fileURLs: Array<URL>?
		do {
			fileURLs = try FileManager.default.contentsOfDirectory(
				at: getDocumentsDirectory(), includingPropertiesForKeys: nil)
		} catch {
			print("Error while enumerating files documents dir: \(error.localizedDescription)")
		}
		return fileURLs
	}
	
	public func getCreationDateOfURL(url: URL) -> Date? {
		var creationDate: Date?
		do {
			let attr = try FileManager.default.attributesOfItem(atPath: url.path)
			creationDate = attr[FileAttributeKey.creationDate] as? Date
		} catch {
			return nil
		}
		return creationDate
	}
	
	public func getURLBundlePathForFile(filename: String, ext: String) -> URL? {
		var resultURL: URL?
		if let path = Bundle.main.url(forResource: filename, withExtension: ext) {
			print("found bundle file")
			resultURL = path
		} else {
			print("bundle file not found: \(filename).\(ext)")
		}
		return resultURL
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
	
	public func getFilesInBundleWithExtension(ext: String) {
		
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

let LOREMIPSOMTESTTEXT: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean accumsan sem nec erat placerat feugiat. Donec congue libero massa, a malesuada ex posuere non. Suspendisse sagittis diam non eros faucibus molestie. Pellentesque lacus eros, elementum vel congue ut, hendrerit et dui. Maecenas pretium convallis metus, vitae fringilla ipsum aliquet vel. Ut eu purus velit. Praesent convallis, ex rutrum gravida tincidunt, massa dui volutpat ipsum, ut eleifend elit nisi ac diam. Morbi ultrices condimentum justo a placerat. Suspendisse potenti. Quisque mollis nulla ac justo maximus ultricies. Proin luctus placerat facilisis. Phasellus ullamcorper dui sed arcu consectetur fermentum. Quisque luctus enim a velit faucibus, ac suscipit metus lacinia. Donec enim orci, vestibulum malesuada urna vel, convallis posuere lacus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse consectetur, risus a venenatis pellentesque, libero diam rhoncus dolor, ut volutpat enim nunc ut quam. Nullam eu nibh vehicula justo auctor pharetra. Morbi vel dolor urna. Integer euismod tincidunt lorem, quis efficitur mauris blandit ut. Quisque ut placerat diam, vel finibus tellus. Pellentesque tincidunt mi et tincidunt lacinia. Donec a metus sit amet arcu pharetra molestie. Nullam finibus nisl a tellus commodo cursus. Suspendisse potenti. Mauris eget feugiat mi. Nulla facilisi. Duis scelerisque lectus a convallis dictum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Curabitur accumsan dolor vitae libero suscipit, eu facilisis augue condimentum. Nam laoreet leo ex, a molestie ex facilisis ut. Ut pellentesque eleifend tincidunt. Donec luctus tellus lacus, non tempor erat mollis quis. Nam nec odio sed mi tincidunt auctor non dapibus augue. Phasellus laoreet felis felis, sed sodales leo ultrices pharetra. Duis egestas nibh pulvinar ante accumsan, a venenatis risus convallis. Quisque vel diam ac velit tincidunt hendrerit. Morbi ac ultrices nisl, et bibendum nisl. Morbi vulputate ut neque ac mattis. Curabitur id ipsum orci. Curabitur ultrices posuere justo ut dignissim. Donec a porta felis. Aliquam erat volutpat. Nunc non est in mi suscipit pretium. Fusce vestibulum est ac nisi porttitor, sed maximus ligula ullamcorper. Aenean pretium diam at leo malesuada hendrerit tempus in dolor. Proin ultrices mauris sollicitudin tempus facilisis. Nulla luctus molestie est, ut molestie lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla semper fermentum ex. Ut consectetur quis ex at venenatis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Suspendisse in enim rutrum, volutpat velit lobortis, commodo orci. Nam nec odio at sem malesuada placerat ut eu ex. Vivamus eget ante ac ipsum pretium mollis sit amet ut quam. Vestibulum sodales sagittis lectus, a auctor justo ornare vel. Etiam tristique sem nibh, sed dictum enim consequat sagittis. Mauris viverra tempus nulla, sed bibendum massa faucibus et. Ut rhoncus consectetur elit, quis ultricies enim congue at. Nam pellentesque nibh velit, eu euismod risus pulvinar ac. Aliquam vel auctor turpis. Mauris cursus convallis est, pharetra tempus leo venenatis non. Cras sit amet varius sem, eu condimentum purus. Nunc lobortis commodo turpis, non pulvinar nibh viverra at. Proin dui turpis, sagittis ultricies turpis sit amet, euismod mollis lorem. "
