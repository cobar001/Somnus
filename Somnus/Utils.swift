//
//  Utils.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

let FONTNAME: String = "Avenir-Roman"
let FONTNAMEBOLD: String = "Avenir-Heavy"

let SCREENBOUNDS: CGRect = UIScreen.main.bounds

let PURPLECOLOR: UIColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1.0)
let ORANGECOLOR: UIColor = UIColor(red: 249/255, green: 105/255, blue: 14/255, alpha: 1.0)
let SUNCOLOR: UIColor = UIColor(red: 238/255, green: 238/255, blue: 0, alpha: 1.0)
let SUNRAYCOLOR: UIColor = UIColor(red: 247/255, green: 202/255, blue: 24/255, alpha: 1.0)

class SomnusUtils {
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
		if hour > 11 { suffix = "PM"; hour -= 12; }
		return String(format: "%d:%02d %@", hour, minute, suffix)
	}
}

enum InputError: Error {
	case InvalidInput
	case NotEnoughInputParameters
	case InvalidInputType
}
