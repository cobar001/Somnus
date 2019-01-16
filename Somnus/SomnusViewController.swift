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

	deinit {
		print("Remove NotificationCenter Deinit")
		// Remove notfications for media player
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		print("screen: \(UIScreen.main.bounds)")
		
		if SCREENBOUNDS.height <= 700 {
			mHasSmallerScreen = true
		}
		
		print("has smaller screen: \(mHasSmallerScreen)")
		
		// Quick set up views, delegates (collection view), current playlists
		// and navigation
		registerDelegates()
		updatePlaylists()
		setUpNav()
		setUpUI()
		// Prepare MediaPlayer for playback
		mMPMediaPlayer.prepareToPlay()
		// Register ViewController to receive mediaplayer playback updates
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateNowPlayingInfo),
			name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
			object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// TODO: Start timers here to they restart everytime the
		// app returns to its running foreground state
		print("view will appear")

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("view did appear")
		checkMediaPlayerPermissions()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// TODO: Reset cloud positions, deactivate timers,
		print("view did disappear")

	}
	
	fileprivate func checkMediaPlayerPermissions() {
		MPMediaLibrary.requestAuthorization { (status: MPMediaLibraryAuthorizationStatus) in
			if status == MPMediaLibraryAuthorizationStatus.denied ||
				status == MPMediaLibraryAuthorizationStatus.restricted ||
				status == MPMediaLibraryAuthorizationStatus.notDetermined {
				print("media player access denied, restricted, or not determined")
				DispatchQueue.main.async {
					self.mStartSomnusSessionButton.isEnabled = false
					let alert: UIAlertController = UIAlertController(
						title: "Permissions Missing",
						message: "Somnus doesn't have acccess to your Music library. Please go to Settings->Somnus and allow Somnus to access Media & Apple Music.",
						preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK",
												  style: UIAlertAction.Style.default,
												  handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			} else if status == MPMediaLibraryAuthorizationStatus.authorized {
				print("media player access authorized")
			} else {
				print("media player access failed")
			}
		}
	}

	fileprivate func setUpNav() {
		// Setup/Hide Nav
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
		
		// Add hidden volume slider
		view.addSubview(mVolumeControlSlider);
		
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
		if mHasSmallerScreen {
			mSetUpContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.68).isActive = true
		} else {
			mSetUpContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.75).isActive = true
		}
		mSetUpContainerView.alpha = 1.0
		
		// Countdown Label and DatePicker StackView and Gestures
		mSetUpContainerView.addSubview(mCountdownExplanationLabel)
		mCountdownExplanationLabel.topAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if mHasSmallerScreen {
			mCountdownExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mCountdownExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}
		
		mSetUpContainerView.addSubview(mCountdownDatePicker)
		mCountdownDatePicker.topAnchor.constraint(equalTo: mCountdownExplanationLabel.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mCountdownDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownDatePicker.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if mHasSmallerScreen {
			mCountdownDatePicker.heightAnchor.constraint(equalToConstant: 75).isActive = true
		} else {
			mCountdownDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		}
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
		if mHasSmallerScreen {
			mCountdownPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mCountdownPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}
		
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
		if mHasSmallerScreen {
			mAlarmPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mAlarmPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}
		
		// Alarm Label and DatePicker StackView and Gestures
		mSetUpContainerView.addSubview(mAlarmDatePicker)
		mAlarmDatePicker.bottomAnchor.constraint(equalTo: mAlarmPlaylistExplanationLabel.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmDatePicker.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if mHasSmallerScreen {
			mAlarmDatePicker.heightAnchor.constraint(equalToConstant: 75).isActive = true
		} else {
			mAlarmDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		}
		mAlarmStr = kSomnusUtils.formatDate(date: mAlarmDatePicker.date, calendar: mAlarmDatePicker.calendar)
		mAlarmDate = mAlarmDatePicker.date
		mAlarmCalendar = mAlarmDatePicker.calendar
		
		mSetUpContainerView.addSubview(mAlarmExplanationLabel)
		mAlarmExplanationLabel.bottomAnchor.constraint(equalTo: mAlarmDatePicker.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmExplanationLabel.centerXAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmExplanationLabel.widthAnchor.constraint(equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if mHasSmallerScreen {
			mAlarmExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mAlarmExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}

		// Somnus Session Container UIView
		view.addSubview(mSomnusSessionContainerView)
		mSomnusSessionContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSomnusSessionContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mSomnusSessionContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		if mHasSmallerScreen {
			mSomnusSessionContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.67).isActive = true
		} else {
			mSomnusSessionContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6).isActive = true
		}
		mSomnusSessionContainerView.alpha = 0.0

		// Somnus Session Countdown, Now Playing, and Alarm Labels
		mSomnusSessionContainerView.addSubview(mNowPlayingContainerView)
		mNowPlayingContainerView.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mNowPlayingContainerView.centerYAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mNowPlayingContainerView.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mNowPlayingContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
		
		mNowPlayingContainerView.addSubview(mNowPlayingAlbumImage)
		mNowPlayingAlbumImage.centerXAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mNowPlayingAlbumImage.topAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mNowPlayingAlbumImage.heightAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.heightAnchor, multiplier:0.63).isActive = true
		mNowPlayingAlbumImage.widthAnchor.constraint(equalTo: mNowPlayingAlbumImage.safeAreaLayoutGuide.heightAnchor).isActive = true
		
		mNowPlayingContainerView.addSubview(mNowPlayingTrackArtistStackView)
		mNowPlayingTrackArtistStackView.centerXAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mNowPlayingTrackArtistStackView.bottomAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mNowPlayingTrackArtistStackView.widthAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mNowPlayingTrackArtistStackView.heightAnchor.constraint(equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.heightAnchor, multiplier:0.33).isActive = true
		mNowPlayingTrackArtistStackView.addArrangedSubview(mNowPlayingTrackLabel)
		mNowPlayingTrackArtistStackView.addArrangedSubview(mNowPlayingArtistLabel)
		
		// Somnus Session Countdown Label
		mSomnusSessionContainerView.addSubview(mCountdownLabel)
		mCountdownLabel.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownLabel.topAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownLabel.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		// Somnus Session Alarm label
		mSomnusSessionContainerView.addSubview(mAlarmLabel)
		mAlarmLabel.centerXAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmLabel.bottomAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mAlarmLabel.widthAnchor.constraint(equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
	}
	
	// Set system volume to kCountdownStartVolume and
	// initialize sountdown steps based on
	// kCountdownStartVolume/kCountdownEndVolume delta
	fileprivate func initializeCountdownVolume() {
		mCurrentVolume = kCountdownStartVolume
		guard let countdownInterval: TimeInterval = mCountdownTimeInterval else {
			print("countdown interval not set")
			return
		}
		mCountdownVolumeStep = (kCountdownStartVolume - kCountdownEndVolume) / Float(countdownInterval)
		changeVolume(new_volume: mCurrentVolume!)
	}
	
	fileprivate func initializeAlarmVolume() {
		mCurrentVolume = kAlarmWakeStartVolume
		guard let countdownInterval: TimeInterval = mAlarmWakeTimeInterval else {
			print("alarm interval not set")
			return
		}
		mAlarmWakeVolumeStep = (kAlarmWakeEndVolume - kAlarmWakeStartVolume) / Float(countdownInterval)
		changeVolume(new_volume: mCurrentVolume!)
	}
	
	/***
	* Delegate Methods
	*/
	
	// Allow uidatepicker to recognize multiple gestures (currently no extra gestures)
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true // Obviously think about the logic of what to return in various cases
	}
	
	// Set both Countdown and Alarm Playlists count
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return mMPMediaPlaylists.count
	}
	
	// Set up both Countdown and Alarm Playlist cells
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let playlistCell: PlaylistCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCellID", for: indexPath) as! PlaylistCell
		playlistCell.mPlaylistLabel.text = mMPMediaPlaylists[indexPath.item].name
		return playlistCell
	}
	
	// Handle collection view selections, handling both countdown and alarm
	// collection views and differentiating based on UICollectionView
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index: Int = indexPath.item
		let selectedPlaylist: MPMediaPlaylist = mMPMediaPlaylists[index]
		if collectionView == mCountdownPlaylistsCollectionView {
			mCountdownPlaylist = selectedPlaylist
			print("countdown collectionview \(String(describing: mCountdownPlaylist?.name!))")
		} else {
			mAlarmPlaylist = selectedPlaylist
			print("alarm collectionview \(String(describing: mAlarmPlaylist?.name!))")
		}
		
	}
	
	/***
	* User Interface Widget Methods
	*/
	
	// Choose random star and scale and reverse scale
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
	
	// Subtle change to sun color over time
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
	
	// Start different timers to call @twinkleStar
	fileprivate func startStarTwinkles() {
		mStarTimer1 = Timer.scheduledTimer(
			timeInterval: 1.0, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 1], repeats: true)
		mStarTimer2 = Timer.scheduledTimer(
			timeInterval: 1.25, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 2], repeats: true)
		mStarTimer3 = Timer.scheduledTimer(
			timeInterval: 1.5, target: self, selector: #selector(twinkleStar(sender:)), userInfo: ["number": 3], repeats: true)
	}
	
	// Start different timer to call @sunRaysAnimation
	fileprivate func startSunRays() {
		mSunRayTimer = Timer.scheduledTimer(
			timeInterval: Double(kSunRayTime),
			target: self,
			selector: #selector(sunRaysAnimation(sender:)),
			userInfo: ["interval": kSunRayTime], repeats: true)
	}
	
	// Create, place, and retain uiviews as stars in random origin in range
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
	
	// Create/Place cloud imageviews outside of screen bounds
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
	
	// Start different timers to call @moveCloud
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
	
	// Places cloud along random y component and x component off the screen.
	// Than move cloud across screen with speed associated with specific cloud (kCloudOneTime, etc.)
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
	
	// Countdown UIDatePicker delegate target
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
			print("\(mAlarmStr)")
		} else {
			print("datepicker mode not supported")
		}
	}
	
	// Start Comnus Session Button target
	@objc func startSomnusSession() {
		print("startSomnusSession")
		print("\(mCountdownStr)")
		print("\(mAlarmStr)")
		// Initialize session values
		//mIsSomnusSessionActive = true
		mCountdownTimeInterval = mCountdownDatePicker.countDownDuration
		mAlarmDate = mAlarmDatePicker.date
		mAlarmCalendar = mAlarmDatePicker.calendar
		mAlarmWakeTimeInterval = TimeInterval(exactly: 300.0)
		// Safely retrieve optional members
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
		// Ensure playlist is selected/valid, otherwise present alert
		if mCountdownPlaylist == nil {
			presentPlaylistError(errorType: PlaylistError.CountdownPlaylistNotChosen)
			return
		}
		if mCountdownPlaylist!.count < 1 {
			presentPlaylistError(errorType: PlaylistError.EmptyCountdownPlaylist)
			return
		}
		if mAlarmPlaylist == nil {
			presentPlaylistError(errorType: PlaylistError.AlarmPlaylistNotChosen)
			return
		}
		if mAlarmPlaylist!.count < 1 {
			presentPlaylistError(errorType: PlaylistError.EmptyAlarmPlaylist)
			return
		}
		// Format countdown and alarm values to present in Somnus Session
		mCountdownLabel.text = kSomnusUtils.formatSeconds(seconds: Double(countdownTimeInterval))
		mAlarmLabel.text = kSomnusUtils.formatDate(date: alarmDate, calendar: alarmCal)
		// Start the selected playlist with MPMediaPlayer
		kSomnusUtils.startPlaylistContinuous(
			mediaPlayer: mMPMediaPlayer, selectedPlaylist: mCountdownPlaylist)
		// Set system volum to kCountdownStartVolume
		initializeCountdownVolume()
		// Animate into the session
		UIView.animate(withDuration: 0.5, animations: {
			self.mSetUpContainerView.alpha = 0.0
			self.mStartSomnusSessionButton.alpha = 0.0
			self.mSomnusSessionContainerView.alpha = 1.0
			self.mStopSomnusSessionButton.alpha = 1.0
			UIScreen.main.brightness = CGFloat(0.01)
		}) { (bool) in
			print("start countdown animation done")
			self.mCountdownTimer?.invalidate()
			self.mCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
												   target: self,
												   selector: #selector(self.updateCountdown),
												   userInfo: nil, repeats: true)
			// Initialize the alarm timer
			self.startAlarmTimer(alarmDate: alarmDate)
		}
	}
	
	// Convenience function to adjust slider to desired volume value (0.0 - 1.0)
	fileprivate func changeVolume(new_volume: Float) {
		if new_volume < 0.0 || new_volume > 1.0 {
			return
		}
		let sliderSubViews = self.mVolumeControlSlider.subviews.filter{
			NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}
		let slider = sliderSubViews.first as? UISlider
		slider?.setValue(new_volume, animated: false)
	}
	
	fileprivate func startAlarmTimer(alarmDate: Date) {
		print("starting alarm")
		mAlarmTimer = Timer.init(
			fireAt: alarmDate, interval: 0,
			target: self,
			selector: #selector(alarmTimeReached),
			userInfo: nil, repeats: false)
		RunLoop.main.add(mAlarmTimer!, forMode: RunLoop.Mode.common)
	}
	
	@objc func alarmTimeReached() {
		if let countdownTimer = mCountdownTimer {
			if countdownTimer.isValid {
				countdownTimer.invalidate()
			}
		}
		mMPMediaPlayer.stop()
		// Start the selected playlist with MPMediaPlayer
		kSomnusUtils.startPlaylistContinuous(
			mediaPlayer: mMPMediaPlayer, selectedPlaylist: mAlarmPlaylist)
		// Set system volum to kCountdownStartVolume
		initializeAlarmVolume()
		mAlarmWakeTimer = Timer.scheduledTimer(timeInterval: 1.0,
											   target: self,
											   selector: #selector(self.updateAlarmWake),
											   userInfo: nil, repeats: true)
		
		print("ALARM ALARM")
	}
	
	// Target of MPMedia now playing notification. Handle now playing UI updates.
	@objc func updateNowPlayingInfo() {
		// check media player for validity
		guard let nowPlayingItem: MPMediaItem = mMPMediaPlayer.nowPlayingItem else {
			print("now playing item nil")
			return
		}
		// get proper sized album artwork if valid
		let nowPlayingArtworkSize: CGSize = CGSize(
			width: mNowPlayingAlbumImage.bounds.width, height: mNowPlayingAlbumImage.bounds.height)
		guard let nowPlayingArtworkImage: UIImage = nowPlayingItem.artwork?.image(at: nowPlayingArtworkSize) else {
			print("error getting track artwork")
			return
		}
		print("now playing changed: \(String(describing: nowPlayingItem.title))")
		mNowPlayingAlbumImage.image = nowPlayingArtworkImage
		// get track title and artist name
		guard let trackName: String = nowPlayingItem.title,
			let trackArtist: String = nowPlayingItem.artist else {
			print("error getting track and artist name")
			return
		}
		mNowPlayingTrackLabel.text = trackName
		mNowPlayingArtistLabel.text = trackArtist
	}
	
	// Load Music playlists into container to populate collection views
	// and subsequently play
	fileprivate func updatePlaylists() {
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
			//print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
		}
		//print("playlists: \(mMPMediaPlaylists.count)")
	}
	
	// Stop Somnus session. Invalidate timers, stop mediaplayer,
	// and animate back to initialization options
	@objc func stopSomnusSession() {
		print("stopSomnusSession")
		//print("\(mCountdownStr)")
		//print("\(mAlarmStr)")
		//mIsSomnusSessionActive = false
		mCountdownTimer?.invalidate()
		mAlarmWakeTimer?.invalidate()
		UIView.animate(withDuration: 0.5, animations: {
			self.mSetUpContainerView.alpha = 1.0
			self.mStartSomnusSessionButton.alpha = 1.0
			self.mSomnusSessionContainerView.alpha = 0.0
			self.mStopSomnusSessionButton.alpha = 0.0
			UIScreen.main.brightness = CGFloat(0.25)
		}) { (bool) in
			print("alarm animation done")
			self.mMPMediaPlayer.stop()
		}
	}
	
	// UI Update Targets
	
	// Countdown timer target, update the current time interval
	// and format/publish new interval to the UI
	@objc func updateCountdown() {
		// TODO: Make 'if let'
		if mCountdownTimeInterval == nil {
			return
		}
		if mCountdownTimeInterval == 0.0 {
			mCountdownTimer?.invalidate()
			mMPMediaPlayer.stop()
			return
		}
		mCountdownTimeInterval! -= 1.0
		mCountdownStr =
			kSomnusUtils.formatSeconds(seconds: Double(mCountdownTimeInterval!))
		self.mCountdownLabel.text = mCountdownStr
		// lower volume
		if mCurrentVolume  == nil || mCountdownVolumeStep == nil {
			return
		}
		mCurrentVolume! -= mCountdownVolumeStep!
		print("new vol: \(mCurrentVolume!)")
		changeVolume(new_volume: mCurrentVolume!)
	}
	
	@objc func updateAlarmWake() {
		if mAlarmWakeTimeInterval == nil {
			return
		}
		if mAlarmWakeTimeInterval == 0.0 {
			stopSomnusSession()
			return
		}
		mAlarmWakeTimeInterval! -= 1.0
		if mCurrentVolume  == nil || mCountdownVolumeStep == nil {
			return
		}
		mCurrentVolume! += mAlarmWakeVolumeStep!
		print("new vol alarm: \(mCurrentVolume!)")
		changeVolume(new_volume: mCurrentVolume!)
	}
	
	/***
	* Error functions
	**/
	
	// Alert Error presentations
	public func presentPlaylistError(errorType: PlaylistError) {
		var alert: UIAlertController?
		switch errorType {
		case PlaylistError.EmptyCountdownPlaylist:
			let playlistName = mCountdownPlaylist?.name ?? ""
			alert = UIAlertController(
				title: "",
				message: "Countdown playlist \(playlistName) contains no songs",
				preferredStyle: UIAlertController.Style.alert)
		case PlaylistError.CountdownPlaylistNotChosen:
			alert = UIAlertController(
				title: "",
				message: "Countdown playlist not chosen",
				preferredStyle: UIAlertController.Style.alert)
		case PlaylistError.EmptyAlarmPlaylist:
			let playlistName = mAlarmPlaylist?.name ?? ""
			alert = UIAlertController(
				title: "",
				message: "Alarm playlist \(playlistName) contains no songs",
				preferredStyle: UIAlertController.Style.alert)
		case PlaylistError.AlarmPlaylistNotChosen:
			alert = UIAlertController(
				title: "",
				message: "Alarm playlist not chosen",
				preferredStyle: UIAlertController.Style.alert)
		}
		alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
		self.present(alert!, animated: true, completion: nil)
	}
	
	/***
	* User Interface Widgets
	*/
	
	// TODO: Life cycle, finalize design,
	// adhere to https://developer.apple.com/app-store/review/
	
	fileprivate let kSomnusUtils: SomnusUtils = SomnusUtils()
	fileprivate var mHasSmallerScreen: Bool = false
	
	fileprivate let kCountdownStartVolume: Float = 0.15
	fileprivate let kCountdownEndVolume: Float = 0.01
	fileprivate var mCountdownVolumeStep: Float?
	
	fileprivate let kAlarmWakeStartVolume: Float = 0.085
	fileprivate let kAlarmWakeEndVolume: Float = 0.255
	fileprivate var mAlarmWakeTimeInterval: TimeInterval?
	fileprivate var mAlarmWakeVolumeStep: Float?
	fileprivate var mAlarmWakeTimer: Timer?
	
	fileprivate var mCurrentVolume: Float?
	fileprivate let mVolumeControlSlider =
		MPVolumeView(frame: CGRect(x: -50, y: -50, width: 0, height: 0))
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
	
	//fileprivate var mIsSomnusSessionActive: Bool = false
	
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
	
	fileprivate let mNowPlayingContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.gray
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mNowPlayingAlbumImage: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "artworkPlaceholder"))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mNowPlayingTrackArtistStackView: UIStackView = {
		let stackview: UIStackView = UIStackView()
		stackview.axis = NSLayoutConstraint.Axis.vertical
		stackview.distribution = UIStackView.Distribution.fillEqually
		stackview.spacing = 0
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()
	
	fileprivate let mNowPlayingTrackLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Track"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.magenta
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mNowPlayingArtistLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Artist"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.blue
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 14)
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
