//
//  SomnusViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit
import MediaPlayer

class SomnusViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

		// Quick set up
		registerDelegates()
		updatePlaylists()
		setUpNav()
		setUpUI()
//		let myPlaylistQuery = MPMediaQuery.playlists()
//		let playlists = myPlaylistQuery.collections
//		for playlist in playlists! {
//			print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
//			let songs = playlist.items
//			for song in songs {
//				let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
//				print("\t\t", songTitle!)
//			}
//		}
//		mMPMediaPlayer.setQueue(with: MPMediaQuery.songs())
//		mMPMediaPlayer.play()
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
	
	fileprivate func registerDelegates() {
		mCountdownPlaylistsCollectionView.delegate = self
		mCountdownPlaylistsCollectionView.dataSource = self
		mAlarmPlaylistsCollectionView.delegate = self
		mAlarmPlaylistsCollectionView.dataSource = self
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
		
		// Moon, Sun, and Somnus ImageView/Button
		
		view.addSubview(mMoonImageView)
		mMoonImageView.topAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
		mMoonImageView.rightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mMoonImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mMoonImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		view.addSubview(mSunImageView)
		mSunImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mSunImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
		mSunImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mSunImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		view.addSubview(mStartSomnusSessionButton)
		mStartSomnusSessionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mStartSomnusSessionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mStartSomnusSessionButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mStartSomnusSessionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		mStartSomnusSessionButton.alpha = 1.0
		
		view.addSubview(mStopSomnusSessionButton)
		mStopSomnusSessionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mStopSomnusSessionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mStopSomnusSessionButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mStopSomnusSessionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		mStopSomnusSessionButton.alpha = 0.0
		
		// Middle line temporary reference  UIView
		
		view.addSubview(mMiddleLineView)
		mMiddleLineView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMiddleLineView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mMiddleLineView.widthAnchor.constraint(equalToConstant: 300).isActive = true
		mMiddleLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		// Set Up Container UIView
		
		view.addSubview(mSetUpContainerView)
		mSetUpContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSetUpContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mSetUpContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		mSetUpContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.75).isActive = true
		mSetUpContainerView.alpha = 1.0
		
		// Countdown Label and DatePicker StackView and Gestures
		
		mSetUpContainerView.addSubview(mCountdownExplanationLabel)
		mCountdownExplanationLabel.topAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		mSetUpContainerView.addSubview(mCountdownDatePicker)
		mCountdownDatePicker.topAnchor.constraint(equalTo: mCountdownExplanationLabel.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mCountdownDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownDatePicker.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		// uidatepicker bugfix
		var countdownDateComponents: DateComponents = DateComponents()
		countdownDateComponents.hour = 0
		countdownDateComponents.minute = 1
		let coutndownCalendar: Calendar = Calendar.current
		let defaultCountdownDate: Date =
			coutndownCalendar.date(from: countdownDateComponents) ?? Date()
		mCountdownDatePicker.setDate(defaultCountdownDate, animated: true)
		mCountdownStr = kSomnusUtils.formatSeconds(
			seconds: Double(mCountdownDatePicker.countDownDuration))
		mCountdownTimeInterval = mCountdownDatePicker.countDownDuration
		
		// Countdown Controls StackView
		
		mSetUpContainerView.addSubview(mCountdownPlaylistExplanationLabel)
		mCountdownPlaylistExplanationLabel.topAnchor.constraint(equalTo: mCountdownDatePicker.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mCountdownPlaylistExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownPlaylistExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		mSetUpContainerView.addSubview(mCountdownPlaylistsCollectionView)
		mCountdownPlaylistsCollectionView.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownPlaylistsCollectionView.topAnchor.constraint(equalTo: mCountdownPlaylistExplanationLabel.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mCountdownPlaylistsCollectionView.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		// Alarm Controls StackView
		
		mSetUpContainerView.addSubview(mAlarmPlaylistsCollectionView)
		mAlarmPlaylistsCollectionView.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmPlaylistsCollectionView.bottomAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mAlarmPlaylistsCollectionView.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		mSetUpContainerView.addSubview(mAlarmPlaylistExplanationLabel)
		mAlarmPlaylistExplanationLabel.bottomAnchor.constraint(equalTo: mAlarmPlaylistsCollectionView.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmPlaylistExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmPlaylistExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		// Alarm Label and DatePicker StackView and Gestures
		
		mSetUpContainerView.addSubview(mAlarmDatePicker)
		mAlarmDatePicker.bottomAnchor.constraint(equalTo: mAlarmPlaylistExplanationLabel.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmDatePicker.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		mAlarmStr = kSomnusUtils.formatDate(date: mAlarmDatePicker.date, calendar: mAlarmDatePicker.calendar)
		mAlarmDate = mAlarmDatePicker.date
		mAlarmCalendar = mAlarmDatePicker.calendar
		
		mSetUpContainerView.addSubview(mAlarmExplanationLabel)
		mAlarmExplanationLabel.bottomAnchor.constraint(equalTo: mAlarmDatePicker.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

		// Somnus Session Container UIView
		
		view.addSubview(mSomnusSessionContainerView)
		mSomnusSessionContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSomnusSessionContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mSomnusSessionContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		mSomnusSessionContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6).isActive = true
		mSomnusSessionContainerView.alpha = 0.0

		// Somnus Session Countdown, Now Playing, and Alarm Labels
		
		mSomnusSessionContainerView.addSubview(mNowPlayingLabel)
		mNowPlayingLabel.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mNowPlayingLabel.centerYAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mNowPlayingLabel.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mNowPlayingLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		mSomnusSessionContainerView.addSubview(mCountdownLabel)
		mCountdownLabel.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownLabel.topAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownLabel.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		mSomnusSessionContainerView.addSubview(mAlarmLabel)
		mAlarmLabel.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmLabel.bottomAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mAlarmLabel.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
	}
	
	/***
	* Delegate Methods
	*/
	
	// Allow uidatepicker to recognize multiple gestures
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true // Obviously think about the logic of what to return in various cases
	}
	
	// Collection View Methods
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return mMPMediaPlaylists.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let playlistCell: PlaylistCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCellID", for: indexPath) as! PlaylistCell
		playlistCell.mPlaylistLabel.text = mMPMediaPlaylists[indexPath.item].name
		return playlistCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index: Int = indexPath.item
		let selectedPlaylist: MPMediaPlaylist = mMPMediaPlaylists[index]
		if collectionView == mCountdownPlaylistsCollectionView {
			print("countdown collectionview")
			mCountdownPlaylist = selectedPlaylist
		} else {
			print("alarm collectionview")
			mAlarmPlaylist = selectedPlaylist
		}
		
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
	
	@objc func startSomnusSession() {
		print("startSomnusSession")
		print("\(mCountdownStr)")
		print("\(mAlarmStr)")
		mIsSomnusSessionActive = true
		mCountdownTimeInterval = mCountdownDatePicker.countDownDuration
		mAlarmDate = mAlarmDatePicker.date
		mAlarmCalendar = mAlarmDatePicker.calendar
		guard let countdownTimeInterval: TimeInterval = mCountdownTimeInterval else {
			print("countdown time interval nil")
			return
		}
		guard let alarmDate: Date = mAlarmDate else {
			print("alarm date nil")
			return
		}
		guard let alarmCal: Calendar = mAlarmCalendar else {
			print("alarm calendar nil")
			return
		}
		mCountdownLabel.text = kSomnusUtils.formatSeconds(seconds: Double(countdownTimeInterval))
		mAlarmLabel.text = kSomnusUtils.formatDate(date: alarmDate, calendar: alarmCal)
		UIView.animate(withDuration: 1.0, animations: {
			self.mSetUpContainerView.alpha = 0.0
			self.mStartSomnusSessionButton.alpha = 0.0
			self.mSomnusSessionContainerView.alpha = 1.0
			self.mStopSomnusSessionButton.alpha = 1.0
		}) { (bool) in
			print("done")
			self.mCountdownTimer?.invalidate()
			self.mCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
												   target: self,
												   selector: #selector(self.updateCountdown),
												   userInfo: nil, repeats: true)
		}
	}
	
	func updatePlaylists() {
		mMPMediaPlaylists.removeAll()
		let myPlaylistQuery = MPMediaQuery.playlists()
		guard let playlists = myPlaylistQuery.collections else {
			return
		}
		for playlist in playlists {
			guard let p = playlist as? MPMediaPlaylist else {
				return
			}
			mMPMediaPlaylists.append(p)
			print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
//			let songs = playlist.items
//			for song in songs {
//				let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
//				print("\t\t", songTitle!)
//			}
		}
		print("playlists: \(mMPMediaPlaylists.count)")
	}
	
	@objc func stopSomnusSession() {
		print("stopSomnusSession")
		print("\(mCountdownStr)")
		print("\(mAlarmStr)")
		mIsSomnusSessionActive = false
		mCountdownTimer?.invalidate()
		UIView.animate(withDuration: 1.0, animations: {
			self.mSetUpContainerView.alpha = 1.0
			self.mStartSomnusSessionButton.alpha = 1.0
			self.mSomnusSessionContainerView.alpha = 0.0
			self.mStopSomnusSessionButton.alpha = 0.0
		}) { (bool) in
			print("done")
		}
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
		self.mCountdownLabel.text = mCountdownStr
	}
	
	/***
	* User Interface Widgets
	*/
	fileprivate let kSomnusUtils: SomnusUtils = SomnusUtils()
	
	fileprivate let mMPMediaPlayer: MPMusicPlayerApplicationController =
		MPMusicPlayerApplicationController.applicationQueuePlayer
	fileprivate var mMPMediaPlaylists: Array<MPMediaPlaylist> = Array<MPMediaPlaylist>()
	fileprivate var mCountdownPlaylist: MPMediaPlaylist?
	fileprivate var mAlarmPlaylist: MPMediaPlaylist?

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
	
	fileprivate var mIsSomnusSessionActive: Bool = false
	
	fileprivate var mCountdownStr: String = "00:00:00"
	fileprivate var mCountdownTimeInterval: TimeInterval?
	fileprivate var mCountdownTimer: Timer?
	
	fileprivate var mAlarmStr: String = "00:00 AM"
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
	
	fileprivate let mSetUpContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.black.cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mCountdownExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Choose music duration:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 18)
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
	
	fileprivate let mCountdownPlaylistExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Choose Playlist:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mCountdownPlaylistsCollectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout  = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
		layout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = UIColor.cyan
		collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCellID")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	fileprivate let mAlarmExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Choose alarm time:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmDatePicker: UIDatePicker = {
		let dp: UIDatePicker = UIDatePicker()
		dp.setValue(UIColor.darkGray, forKeyPath: "textColor")
		dp.isUserInteractionEnabled = true
		dp.backgroundColor = UIColor.cyan
		dp.datePickerMode = UIDatePicker.Mode.time
		dp.addTarget(self, action: #selector(datePickerChanged(sender:)),
					 for: UIControl.Event.valueChanged)
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()
	
	fileprivate let mAlarmPlaylistExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Choose Playlist:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmPlaylistsCollectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout  = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
		layout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = UIColor.cyan
		collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCellID")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	fileprivate let mStartSomnusSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.green
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.setTitle("start", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(startSomnusSession),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mSomnusSessionContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.black.cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mCountdownLabel: UILabel = {
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
	
	fileprivate let mNowPlayingLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Now Playing"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.gray
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 36)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "00:00 AM"
		label.textColor = UIColor.darkGray
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 56)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mSunImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "sun"))
		view.image = view.image?.withRenderingMode(.alwaysTemplate)
		view.tintColor = SUNCOLOR
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mStopSomnusSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.red
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.setTitle("stop", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(stopSomnusSession),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
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
