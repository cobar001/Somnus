//
//  SomnusViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

class SomnusViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

		// Quick set up
		setUpNav()
		setUpUI()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// TODO: Start timers here to they restart everytime the
		// app returns to its running foreground state
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// TODO: Reset cloud positions, deactivate timers,
	}

	fileprivate func setUpNav() {
		// Hide Nav
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
		self.navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func setUpUI() {
		
		// Set up Background gradient
		
		let gradient = CAGradientLayer()
		gradient.frame = view.safeAreaLayoutGuide.layoutFrame
		let purple: CGColor = PURPLECOLOR.cgColor
		let orange: CGColor = ORANGECOLOR.cgColor
		gradient.colors = [purple, orange]
		view.layer.insertSublayer(gradient, at: 0)
		
		// Start Clouds and Sun animations
		
		populateStarContainer()
		startStarTwinkles()
		startSunRays()
		
		registerClouds()
		startCloudMovement()
		
		// Moon ImageView
		
		view.addSubview(mMoonImageView)
		mMoonImageView.topAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
		mMoonImageView.rightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mMoonImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mMoonImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		// Middle line temporary reference  UIView
		
		view.addSubview(mMiddleLineView)
		mMiddleLineView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMiddleLineView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mMiddleLineView.widthAnchor.constraint(equalToConstant: 300).isActive = true
		mMiddleLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		// Countdown Label and DatePicker StackView and Gestures
		
		view.addSubview(mCountdownTimerStackView)
		mCountdownTimerStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		mCountdownTimerStackView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SCREENBOUNDS.height * 0.25).isActive = true
		mCountdownTimerStackView.widthAnchor.constraint(
			equalToConstant: SCREENBOUNDS.width * 2).isActive = true
		mCountdownTimerStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		mCountdownTimerStackView.addArrangedSubview(mTimerLabel)
		mCountdownTimerStackView.addArrangedSubview(mCountdownDatePicker)
		// uidatepicker bugfix
		var countdownDateComponents: DateComponents = DateComponents()
		countdownDateComponents.hour = 0
		countdownDateComponents.minute = 1
		let coutndownCalendar: Calendar = Calendar.current
		let defaultCountdownDate: Date =
			coutndownCalendar.date(from: countdownDateComponents) ?? Date()
		mCountdownDatePicker.setDate(defaultCountdownDate, animated: true)
		let tapTimerCountdownTapGestureRecgonizer: UITapGestureRecognizer =
			UITapGestureRecognizer(target: self, action: #selector(countdownTimerTapped))
		tapTimerCountdownTapGestureRecgonizer.numberOfTapsRequired = 2
		tapTimerCountdownTapGestureRecgonizer.delegate = self
		let tapDatePickerCountdownTapGestureRecgonizer: UITapGestureRecognizer =
			UITapGestureRecognizer(target: self, action: #selector(countdownDatePickerTapped))
		tapDatePickerCountdownTapGestureRecgonizer.numberOfTapsRequired = 2
		tapDatePickerCountdownTapGestureRecgonizer.delegate = self
		mTimerLabel.addGestureRecognizer(tapTimerCountdownTapGestureRecgonizer)
		mCountdownDatePicker.addGestureRecognizer(tapDatePickerCountdownTapGestureRecgonizer)
		
		// Countdown Controls StackView
		
		view.addSubview(mCountdownControlStackView)
		mCountdownControlStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownControlStackView.topAnchor.constraint(equalTo: mCountdownTimerStackView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mCountdownControlStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		mCountdownControlStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		mCountdownControlStackView.addArrangedSubview(mCountdownPlaylistButton)
		mCountdownControlStackView.addArrangedSubview(mCountdownStartStopButton)
		
		// Alarm Label and DatePicker StackView and Gestures
		
		view.addSubview(mAlarmStackView)
		mAlarmStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		mAlarmStackView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SCREENBOUNDS.height * 0.6).isActive = true
		mAlarmStackView.widthAnchor.constraint(
			equalToConstant: SCREENBOUNDS.width * 2).isActive = true
		mAlarmStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		mAlarmStackView.addArrangedSubview(mAlarmLabel)
		mAlarmStackView.addArrangedSubview(mAlarmDatePicker)
		let tapAlarmTapGestureRecgonizer: UITapGestureRecognizer =
			UITapGestureRecognizer(target: self, action: #selector(alarmTapped))
		tapAlarmTapGestureRecgonizer.numberOfTapsRequired = 2
		tapAlarmTapGestureRecgonizer.delegate = self
		let tapDatePickerAlarmTapGestureRecgonizer: UITapGestureRecognizer =
			UITapGestureRecognizer(target: self, action: #selector(alarmDatePickerTapped))
		tapDatePickerAlarmTapGestureRecgonizer.numberOfTapsRequired = 2
		tapDatePickerAlarmTapGestureRecgonizer.delegate = self
		mAlarmLabel.addGestureRecognizer(tapAlarmTapGestureRecgonizer)
		mAlarmDatePicker.addGestureRecognizer(tapDatePickerAlarmTapGestureRecgonizer)
		
		// Alarm Controls StackView
		
		view.addSubview(mAlarmControlStackView)
		mAlarmControlStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmControlStackView.topAnchor.constraint(equalTo: mAlarmStackView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mAlarmControlStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		mAlarmControlStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		mAlarmControlStackView.addArrangedSubview(mAlarmPlaylistButton)
		mAlarmControlStackView.addArrangedSubview(mAlarmEnableDisableButton)
		
		// Sun Image View
		
		view.addSubview(mSunImageView)
		mSunImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mSunImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
		mSunImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mSunImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true

	}
	
	/***
	* Delegate Methods
	*/
	
	// Allow uidatepicker to recognize multiple gestures
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true // Obviously think about the logic of what to return in various cases
	}
	
	/***
	* User Interface Widget Methods
	*/
	
	// Set up animations and background portions
	
	@objc func twinkleStar(sender: Timer) {
		// choose star in container to twinkle
		guard let userInfo = sender.userInfo as? [String: Int] else {
			return
		}
		let timerNumber = userInfo["number"]
		var starContainer: Array<UIView>!
		switch timerNumber {
		case 1:
			starContainer = mStarContainer1
		case 2:
			starContainer = mStarContainer2
		case 3:
			starContainer = mStarContainer3
		default:
			break
		}
		let randomIndex: Int = Int.random(in: 0..<starContainer.count)
		let randomStarView: UIView = starContainer[randomIndex]
		let originalTransform: CGAffineTransform = randomStarView.transform
		let scaledTransform: CGAffineTransform = originalTransform.scaledBy(x: 3.0, y: 3.0)
		UIView.animate(withDuration: 0.5, animations: {
			randomStarView.transform = scaledTransform
		}) { (Bool) in
			UIView.animate(withDuration: 0.5, animations: {
				randomStarView.transform = originalTransform
			})
		}
	}
	
	@objc func sunRaysAnimation(sender: Timer) {
		guard let userInfo = sender.userInfo as? [String: Int] else {
			return
		}
		guard let interval: Int = userInfo["index"] else {
			return
		}
		UIView.animate(withDuration: Double(interval) / 2.0, animations: {
			self.mSunImageView.tintColor = SUNRAYCOLOR
		}) { (Bool) in
			UIView.animate(withDuration: Double(interval) / 2.0, animations: {
				self.mSunImageView.tintColor = SUNCOLOR
			})
		}
	}
	
	fileprivate func startStarTwinkles() {
		mStarTimer1 = Timer.scheduledTimer(
			timeInterval: 1.0, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 1], repeats: true)
		mStarTimer2 = Timer.scheduledTimer(
			timeInterval: 1.25, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 2], repeats: true)
		mStarTimer3 = Timer.scheduledTimer(
			timeInterval: 1.5, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 3], repeats: true)
	}
	
	fileprivate func startSunRays() {
		mSunRayTimer = Timer.scheduledTimer(
			timeInterval: Double(kSunRayTime),
			target: self,
			selector: #selector(sunRaysAnimation(sender:)),
			userInfo: ["interval": kSunRayTime], repeats: true)
	}
	
	fileprivate func populateStarContainer() {
		let widthBounds: Array<Int> = [0, Int(SCREENBOUNDS.width)]
		let heightBounds1: Array<Int> = [0, Int(SCREENBOUNDS.height * 0.25)]
		let heightBounds2: Array<Int> = [Int(SCREENBOUNDS.height * 0.25),
										 Int(SCREENBOUNDS.height * 0.33)]
		for i in 0 ..< 150 {
			do {
				var starPoint: CGPoint!
				if i < 130 {
					starPoint = try kSomnusUtils.generateRandomPositionWithBounds(
						widthBounds: widthBounds, heightBounds: heightBounds1)
				} else {
					starPoint = try kSomnusUtils.generateRandomPositionWithBounds(
						widthBounds: widthBounds, heightBounds: heightBounds2)
				}
				let starView: UIView =
					UIView(frame: CGRect(x: starPoint.x, y: starPoint.y, width: 1.0, height: 1.0))
				starView.backgroundColor = UIColor.white
				starView.layer.cornerRadius = 0.5
				starView.clipsToBounds = true
				view.addSubview(starView)
				if i < 50 {
					mStarContainer1.append(starView)
				} else if i < 100 {
					mStarContainer2.append(starView)
				} else {
					mStarContainer3.append(starView)
				}
			} catch {
				print("Error generateRandomPositionWithBounds")
			}
		}
	}
	
	fileprivate func registerClouds() {
		mCloudOneImageView = UIImageView(frame: kCloudOneOrigin)
		mCloudOneImageView.image = UIImage(named: "cloud1")
		view.addSubview(mCloudOneImageView)
		mCloudContainer.append(mCloudOneImageView)
		mCloudTwoImageView = UIImageView(frame: kCloudTwoOrigin)
		mCloudTwoImageView.image = UIImage(named: "cloud2")
		view.addSubview(mCloudTwoImageView)
		mCloudContainer.append(mCloudTwoImageView)
		mCloudThreeImageView = UIImageView(frame: kCloudThreeOrigin)
		mCloudThreeImageView.image = UIImage(named: "cloud3")
		view.addSubview(mCloudThreeImageView)
		mCloudContainer.append(mCloudThreeImageView)
	}
	
	fileprivate func startCloudMovement() {
		mCloudTimer1 = Timer.scheduledTimer(
			timeInterval: Double(kCloudOneTime),
			target: self,
			selector: #selector(moveCloud(sender:)),
			userInfo: ["index": 0, "interval": kCloudOneTime],
			repeats: true)
		mCloudTimer2 = Timer.scheduledTimer(
			timeInterval: Double(kCloudTwoTime),
			target: self,
			selector: #selector(moveCloud(sender:)),
			userInfo: ["index": 1, "interval": kCloudTwoTime],
			repeats: true)
		mCloudTimer3 = Timer.scheduledTimer(
			timeInterval: Double(kCloudThreeTime),
			target: self,
			selector: #selector(moveCloud(sender:)),
			userInfo: ["index": 2, "interval": kCloudThreeTime],
			repeats: true)
	}
	
	@objc func moveCloud(sender: Timer) {
		guard let userInfo = sender.userInfo as? [String: Int] else {
			return
		}
		guard let cloudIndex: Int = userInfo["index"] else {
			return
		}
		guard let cloudInterval: Int = userInfo["interval"] else {
			return
		}
		let cloudImageView: UIImageView = mCloudContainer[cloudIndex]
		let leftSide: Bool = Bool.random()
		let randomY: CGFloat = CGFloat.random(in: kMinCloudBound..<kMaxCloudBound)
		let leftX: CGFloat = 0 - cloudImageView.frame.width
		let rightX: CGFloat = SCREENBOUNDS.width + cloudImageView.frame.width
		if leftSide {
			cloudImageView.frame = CGRect(x: leftX,
										  y: randomY,
										  width: cloudImageView.frame.width,
										  height: cloudImageView.frame.width)
			UIView.animate(withDuration: Double(cloudInterval)) {
				cloudImageView.frame.origin.x += (rightX - leftX)
			}
		} else {
			cloudImageView.frame = CGRect(x: rightX,
										  y: randomY,
										  width: cloudImageView.frame.width,
										  height: cloudImageView.frame.width)
			UIView.animate(withDuration: Double(cloudInterval)) {
				cloudImageView.frame.origin.x -= (rightX - leftX)
			}
		}
	}
	
	// Gesture Targets
	
	@objc func countdownTimerTapped() {
		UIView.animate(withDuration: 1.0, animations: {
			self.mCountdownTimerStackView.frame.origin.x -= SCREENBOUNDS.width
			self.mCountdownControlStackView.frame.origin.x -= SCREENBOUNDS.width
		}) { (Bool) in
			print("done")
		}
	}
	
	@objc func countdownDatePickerTapped() {
		UIView.animate(withDuration: 1.0, animations: {
			self.mCountdownTimerStackView.frame.origin.x += SCREENBOUNDS.width
			self.mCountdownControlStackView.frame.origin.x += SCREENBOUNDS.width
			self.mTimerLabel.text = self.mCountdownStr
		}) { (Bool) in
			print("done")
		}
	}
	
	@objc func alarmTapped() {
		UIView.animate(withDuration: 1.0, animations: {
			self.mAlarmStackView.frame.origin.x -= SCREENBOUNDS.width
			self.mAlarmControlStackView.frame.origin.x -= SCREENBOUNDS.width
		}) { (Bool) in
			print("done")
		}
	}
	
	@objc func alarmDatePickerTapped() {
		UIView.animate(withDuration: 1.0, animations: {
			self.mAlarmStackView.frame.origin.x += SCREENBOUNDS.width
			self.mAlarmControlStackView.frame.origin.x += SCREENBOUNDS.width
			self.mAlarmLabel.text = self.mAlarmStr
		}) { (Bool) in
			print("done")
		}
	}
	
	// DatePicker delegate targets
	
	@objc func datePickerChanged(sender: UIDatePicker) {
		if sender.datePickerMode == UIDatePicker.Mode.countDownTimer {
			// editing countdown datepicker
			print("\(sender.countDownDuration)")
			mCountdownTimeInterval = sender.countDownDuration
			mCountdownStr = kSomnusUtils.formatSeconds(seconds: Double(mCountdownTimeInterval!))
		} else if sender.datePickerMode == UIDatePicker.Mode.time {
			// editing alarm time
			mAlarmDate = sender.date
			mAlarmCalendar = sender.calendar
			mAlarmStr = kSomnusUtils.formatDate(date: mAlarmDate!, calendar: mAlarmCalendar!)
		} else {
			print("datepicker mode not supported")
		}
	}
	
	// Button Targets
	
	@objc func countdownPlaylistsButtonPressed() {
		print("countdownPlaylistsButtonPressed")
		//		let notificationsController: NotificationsViewController = NotificationsViewController()
		//		self.navigationController?.pushViewController(notificationsController, animated: true)
	}
	
	@objc func alarmPlaylistButtonPressed() {
		print("alarmPlaylistButtonPressed")
	}
	
	@objc func alarmEnableDisableButtonPressed() {
		print("alarmEnableDisableButtonPressed")
		mAlarmTimer?.invalidate()
	}
	
	@objc func countdownStartStopButtonPressed() {
		print("countdownStartStopButtonPressed")
		guard let countdownTimeInterval: TimeInterval = mCountdownTimeInterval else {
			return
		}
		print("\(Double(countdownTimeInterval))")
		mCountdownTimer?.invalidate()
		mCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
											   target: self,
											   selector: #selector(updateCountdown),
											   userInfo: nil, repeats: true)
	}
	
	// UI Update Targets
	
	@objc func updateCountdown() {
		if mCountdownTimeInterval == nil {
			return
		}
		if mCountdownTimeInterval == 0.0 {
			mCountdownTimer?.invalidate()
			return
		}
		mCountdownTimeInterval! -= 1.0
		mCountdownStr =
			kSomnusUtils.formatSeconds(seconds: Double(mCountdownTimeInterval!))
		self.mTimerLabel.text = mCountdownStr
	}
	
	/***
	* User Interface Widgets
	*/
	fileprivate let kSomnusUtils: SomnusUtils = SomnusUtils()
	
	fileprivate var mStarTimer1: Timer?
	fileprivate var mStarTimer2: Timer?
	fileprivate var mStarTimer3: Timer?
	fileprivate var mStarContainer1: Array<UIView> = Array<UIView>()
	fileprivate var mStarContainer2: Array<UIView> = Array<UIView>()
	fileprivate var mStarContainer3: Array<UIView> = Array<UIView>()
	
	fileprivate var mSunRayTimer: Timer?
	fileprivate var mSunRayContainer1: Array<UIView> = Array<UIView>()
	fileprivate let kSunRayTime: Int = 5
	
	fileprivate var mCloudTimer1: Timer?
	fileprivate var mCloudTimer2: Timer?
	fileprivate var mCloudTimer3: Timer?
	fileprivate var mCloudContainer: Array<UIImageView> = Array<UIImageView>()
	
	fileprivate var mCountdownStr: String = "00:00:00"
	fileprivate var mCountdownTimeInterval: TimeInterval?
	fileprivate var mCountdownTimer: Timer?
	
	fileprivate var mAlarmStr: String = "10:15 AM"
	fileprivate var mAlarmTimer: Timer?
	fileprivate var mAlarmDate: Date?
	fileprivate var mAlarmCalendar: Calendar?
	
	
	fileprivate let mMiddleLineView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.white
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	 fileprivate let mMoonImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "moon"))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let mCountdownTimerStackView: UIStackView = {
		let stackview: UIStackView = UIStackView()
		stackview.axis = NSLayoutConstraint.Axis.horizontal
		stackview.distribution = UIStackView.Distribution.fillEqually
		stackview.spacing = 0
		stackview.isUserInteractionEnabled = true
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()
	
	fileprivate let mTimerLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "00:00:00"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.gray
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 56)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mCountdownDatePicker: UIDatePicker = {
		let dp: UIDatePicker = UIDatePicker()
		dp.setValue(UIColor.white, forKeyPath: "textColor")
		dp.isUserInteractionEnabled = true
		dp.backgroundColor = UIColor.gray
		dp.datePickerMode = UIDatePicker.Mode.countDownTimer
		dp.addTarget(self, action: #selector(datePickerChanged(sender:)),
					 for: UIControl.Event.valueChanged)
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()
	
	let mCountdownControlStackView: UIStackView = {
		let stackview: UIStackView = UIStackView()
		stackview.axis = NSLayoutConstraint.Axis.horizontal
		stackview.distribution = UIStackView.Distribution.fillEqually
		stackview.spacing = 0
		stackview.isUserInteractionEnabled = true
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()
	
	fileprivate let mCountdownPlaylistButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.yellow
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.setTitle("Playlist", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(countdownPlaylistsButtonPressed),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mCountdownStartStopButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.green
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.setTitle("Start", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(countdownStartStopButtonPressed),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let mAlarmStackView: UIStackView = {
		let stackview: UIStackView = UIStackView()
		stackview.axis = NSLayoutConstraint.Axis.horizontal
		stackview.distribution = UIStackView.Distribution.fillEqually
		stackview.spacing = 0
		stackview.isUserInteractionEnabled = true
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()
	
	fileprivate let mAlarmLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "10:15 AM"
		label.textColor = UIColor.darkGray
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 56)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmDatePicker: UIDatePicker = {
		let dp: UIDatePicker = UIDatePicker()
		dp.setValue(UIColor.darkGray, forKeyPath: "textColor")
		dp.isUserInteractionEnabled = true
		dp.backgroundColor = UIColor.magenta
		dp.datePickerMode = UIDatePicker.Mode.time
		dp.addTarget(self, action: #selector(datePickerChanged(sender:)),
					 for: UIControl.Event.valueChanged)
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()
	
	let mAlarmControlStackView: UIStackView = {
		let stackview: UIStackView = UIStackView()
		stackview.axis = NSLayoutConstraint.Axis.horizontal
		stackview.distribution = UIStackView.Distribution.fillEqually
		stackview.spacing = 0
		stackview.isUserInteractionEnabled = true
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()
	
	fileprivate let mAlarmPlaylistButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.yellow
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.setTitle("Playlist", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(alarmPlaylistButtonPressed),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mAlarmEnableDisableButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.green
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.setTitle("Enable", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(alarmEnableDisableButtonPressed),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mSunImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "sun"))
		view.image = view.image?.withRenderingMode(.alwaysTemplate)
		view.tintColor = SUNCOLOR
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate var mCloudOneImageView: UIImageView!
	fileprivate let kCloudOneOrigin: CGRect = CGRect(x: -1000, y: 450, width: 115, height: 60)
	fileprivate let kCloudOneTime: Int = 10
	fileprivate var mCloudTwoImageView: UIImageView!
	fileprivate let kCloudTwoOrigin: CGRect = CGRect(x: -1000, y: 400, width: 130, height: 90)
	fileprivate let kCloudTwoTime: Int = 15
	fileprivate var mCloudThreeImageView: UIImageView!
	fileprivate let kCloudThreeOrigin: CGRect = CGRect(x: -1000, y: 500, width: 110, height: 70)
	fileprivate let kCloudThreeTime: Int = 20
	fileprivate let kMinCloudBound: CGFloat = SCREENBOUNDS.height / 2.0
	fileprivate let kMaxCloudBound: CGFloat = (SCREENBOUNDS.height / 2.0) + 100.0
}
