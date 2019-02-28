//
//  SomnusViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/2/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

class SomnusViewController: UIViewController, UIGestureRecognizerDelegate,
	UICollectionViewDelegate, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout {

	deinit {
		print("Remove NotificationCenter Deinit")
		// Remove notfications for media player
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		// Quick set up views, delegates (collection view), current playlists
		// and navigation
		setUpNav()
		setUpUI()
		registerDelegates()
		
		// Ask for notification permissions to warn when app enter background.
		if !SomnusUtils.shared.checkNotificationCenterPermissions() {
			SomnusUtils.shared.requestNotificationCenterAuthorization()
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.isNavigationBarHidden = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	fileprivate func setUpNav() {
		// Setup/Hide Nav
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationItem.backBarButtonItem =
			UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
		self.navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func registerDelegates() {
		mCountdownPlaylistsCollectionView.delegate = self
		mCountdownPlaylistsCollectionView.dataSource = self
		mAlarmPlaylistsCollectionView.delegate = self
		mAlarmPlaylistsCollectionView.dataSource = self
		mMenuScreenEdgePanGestureRecognizer.delegate = self
		mMenuBackgroundPanGestureRecognizer.delegate = self
		mMenuBackgroundTapGestureRecognizer.delegate = self
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
		mSunImageView.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mSunImageView.leftAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
		mSunImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mSunImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		
		// Start, Stop, and Snooze buttons
		view.addSubview(mStartSomnusSessionButton)
		mStartSomnusSessionButton.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mStartSomnusSessionButton.rightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mStartSomnusSessionButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mStartSomnusSessionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		view.addSubview(mStopSomnusSessionButton)
		mStopSomnusSessionButton.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mStopSomnusSessionButton.rightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
		mStopSomnusSessionButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mStopSomnusSessionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		mStopSomnusSessionButton.alpha = 0.0
		
		view.addSubview(mSnoozeSomnusSessionButton)
		mSnoozeSomnusSessionButton.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		mSnoozeSomnusSessionButton.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSnoozeSomnusSessionButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mSnoozeSomnusSessionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		mSnoozeSomnusSessionButton.alpha = 0.0
		
		view.addSubview(mSnoozeLabel)
		mSnoozeLabel.bottomAnchor.constraint(
			equalTo: mSnoozeSomnusSessionButton.safeAreaLayoutGuide.topAnchor, constant: -8).isActive = true
		mSnoozeLabel.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSnoozeLabel.sizeToFit()
		mSnoozeLabel.alpha = 0.0
		mSnoozeLabel.text = SomnusUtils.shared.formatSeconds(seconds: 300)
		
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
		mSetUpContainerView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSetUpContainerView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mSetUpContainerView.widthAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mSetUpContainerView.heightAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.68).isActive = true
		} else {
			mSetUpContainerView.heightAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.67).isActive = true
		}
		mSetUpContainerView.alpha = 1.0
		
		// Countdown Label and DatePicker StackView and Gestures
		mSetUpContainerView.addSubview(mCountdownExplanationLabel)
		mCountdownExplanationLabel.topAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownExplanationLabel.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownExplanationLabel.widthAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mCountdownExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mCountdownExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}
		
		mSetUpContainerView.addSubview(mCountdownDatePicker)
		mCountdownDatePicker.topAnchor.constraint(
			equalTo: mCountdownExplanationLabel.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mCountdownDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownDatePicker.widthAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mCountdownDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		} else {
			mCountdownDatePicker.heightAnchor.constraint(equalToConstant: 125).isActive = true
		}
		
		mSetUpContainerView.addSubview(mCountdownPlaylistChosenLabel)
		mCountdownPlaylistChosenLabel.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.centerXAnchor).isActive = true
		mCountdownPlaylistChosenLabel.topAnchor.constraint(
			equalTo: mCountdownDatePicker.bottomAnchor, constant: 8).isActive = true
		mCountdownPlaylistChosenLabel.widthAnchor.constraint(
			equalTo: mSetUpContainerView.widthAnchor).isActive = true
		mCountdownPlaylistChosenLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		// uidatepicker bugfix
		var countdownDateComponents: DateComponents = DateComponents()
		countdownDateComponents.hour = 0
		countdownDateComponents.minute = 1
		let coutndownCalendar: Calendar = Calendar.current
		let defaultCountdownDate: Date =
			coutndownCalendar.date(from: countdownDateComponents) ?? Date()
		mCountdownDatePicker.setDate(defaultCountdownDate, animated: true)
		mCountdownStr = SomnusUtils.shared.formatSeconds(
			seconds: Double(mCountdownDatePicker.countDownDuration))
		mCountdownTimeInterval = mCountdownDatePicker.countDownDuration
		
		mSetUpContainerView.addSubview(mAlarmPlaylistChosenLabel)
		mAlarmPlaylistChosenLabel.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.centerXAnchor).isActive = true
		mAlarmPlaylistChosenLabel.bottomAnchor.constraint(
			equalTo: mSetUpContainerView.bottomAnchor).isActive = true
		mAlarmPlaylistChosenLabel.widthAnchor.constraint(
			equalTo: mSetUpContainerView.widthAnchor).isActive = true
		mAlarmPlaylistChosenLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		mSetUpContainerView.addSubview(mAlarmDatePicker)
		mAlarmDatePicker.bottomAnchor.constraint(
			equalTo: mAlarmPlaylistChosenLabel.safeAreaLayoutGuide.topAnchor, constant: -8).isActive = true
		mAlarmDatePicker.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmDatePicker.widthAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mAlarmDatePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
		} else {
			mAlarmDatePicker.heightAnchor.constraint(equalToConstant: 125).isActive = true
		}
		mAlarmStr = SomnusUtils.shared.formatDate(
			date: mAlarmDatePicker.date,
			calendar: mAlarmDatePicker.calendar)
		mAlarmDate = mAlarmDatePicker.date
		mAlarmCalendar = mAlarmDatePicker.calendar
		
		mSetUpContainerView.addSubview(mAlarmExplanationLabel)
		mAlarmExplanationLabel.bottomAnchor.constraint(
			equalTo: mAlarmDatePicker.safeAreaLayoutGuide.topAnchor).isActive = true
		mAlarmExplanationLabel.centerXAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmExplanationLabel.widthAnchor.constraint(
			equalTo: mSetUpContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mAlarmExplanationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		} else {
			mAlarmExplanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}

		// Somnus Session Container UIView
		view.addSubview(mSomnusSessionContainerView)
		mSomnusSessionContainerView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mSomnusSessionContainerView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mSomnusSessionContainerView.widthAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
		mSomnusSessionContainerView.heightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.67).isActive = true
		mSomnusSessionContainerView.alpha = 0.0

		// Somnus Session Countdown, Now Playing, and Alarm Labels
		mSomnusSessionContainerView.addSubview(mRecordingImageView)
		mRecordingImageView.centerXAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mRecordingImageView.centerYAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mRecordingImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		mRecordingImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		mSomnusSessionContainerView.addSubview(mRecordingLabel)
		mRecordingLabel.centerXAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mRecordingLabel.topAnchor.constraint(
			equalTo: mRecordingImageView.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
		mRecordingLabel.sizeToFit()
		
//		mSomnusSessionContainerView.addSubview(mNowPlayingContainerView)
//		mNowPlayingContainerView.centerXAnchor.constraint(
//			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
//		mNowPlayingContainerView.centerYAnchor.constraint(
//			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
//		mNowPlayingContainerView.widthAnchor.constraint(
//			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
//		mNowPlayingContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
//
//		mNowPlayingContainerView.addSubview(mNowPlayingAlbumImage)
//		mNowPlayingAlbumImage.centerXAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
//		mNowPlayingAlbumImage.topAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
//		mNowPlayingAlbumImage.heightAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.heightAnchor, multiplier:0.63).isActive = true
//		mNowPlayingAlbumImage.widthAnchor.constraint(
//			equalTo: mNowPlayingAlbumImage.safeAreaLayoutGuide.heightAnchor).isActive = true
//
//		mNowPlayingContainerView.addSubview(mNowPlayingTrackArtistStackView)
//		mNowPlayingTrackArtistStackView.centerXAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
//		mNowPlayingTrackArtistStackView.bottomAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
//		mNowPlayingTrackArtistStackView.widthAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
//		mNowPlayingTrackArtistStackView.heightAnchor.constraint(
//			equalTo: mNowPlayingContainerView.safeAreaLayoutGuide.heightAnchor, multiplier:0.33).isActive = true
//		mNowPlayingTrackArtistStackView.addArrangedSubview(mNowPlayingTrackLabel)
//		mNowPlayingTrackArtistStackView.addArrangedSubview(mNowPlayingArtistLabel)
		
		// Somnus Session Countdown Label
		mSomnusSessionContainerView.addSubview(mCountdownLabel)
		mCountdownLabel.centerXAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mCountdownLabel.topAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mCountdownLabel.widthAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mCountdownLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		// Somnus Session Alarm label
		mSomnusSessionContainerView.addSubview(mAlarmLabel)
		mAlarmLabel.centerXAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mAlarmLabel.bottomAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mAlarmLabel.widthAnchor.constraint(
			equalTo: mSomnusSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mAlarmLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
	
		// Add Menu/Menu Background views and button lastly
		view.addSubview(mMenuButton)
		mMenuButton.topAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
		mMenuButton.leftAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
		mMenuButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		mMenuButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
		
		view.addSubview(mMenuBackgroundView)
		mMenuBackgroundView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuBackgroundView.widthAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
		mMenuBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mMenuBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mMenuBackgroundPanGestureRecognizer = UIPanGestureRecognizer(
			target: self, action: #selector(menuBackgroundPanned(sender:)))
		mMenuBackgroundTapGestureRecognizer = UITapGestureRecognizer(
			target: self, action: #selector(menuBackgroundTapped(sender:)))
		mMenuBackgroundView.addGestureRecognizer(mMenuBackgroundPanGestureRecognizer)
		mMenuBackgroundView.addGestureRecognizer(mMenuBackgroundTapGestureRecognizer)
		mMenuBackgroundView.alpha = 0
		mMenuBackgroundView.isHidden = true
		
		view.addSubview(mMenuView)
		mMenuWidthConstraint = mMenuView.widthAnchor.constraint(equalToConstant: 250)
		mMenuLeftConstraint = mMenuView.leftAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.leftAnchor)
		mMenuWidthConstraint.isActive = true
		mMenuLeftConstraint.isActive = true
		mMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mMenuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mMenuLeftConstraint.constant = -mMenuWidthConstraint.constant

		mMenuView.addSubview(mMenuContainerView)
		mMenuContainerView.topAnchor.constraint(
			equalTo: mMenuView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		mMenuContainerView.leftAnchor.constraint(
			equalTo: mMenuView.safeAreaLayoutGuide.leftAnchor).isActive = true
		mMenuContainerView.rightAnchor.constraint(
			equalTo: mMenuView.safeAreaLayoutGuide.rightAnchor).isActive = true
		mMenuContainerView.heightAnchor.constraint(equalToConstant: 650).isActive = true
		
		mMenuContainerView.addSubview(mMenuOptionsLabel)
		mMenuOptionsLabel.centerXAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuOptionsLabel.topAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		mMenuOptionsLabel.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mMenuOptionsLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true

		mMenuContainerView.addSubview(mMenuDividerLineView)
		mMenuDividerLineView.centerXAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuDividerLineView.topAnchor.constraint(
			equalTo: mMenuOptionsLabel.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mMenuDividerLineView.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mMenuDividerLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

		mMenuContainerView.addSubview(mMenuSleepVolumeLabel)
		mMenuSleepVolumeLabel.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mMenuSleepVolumeLabel.topAnchor.constraint(
			equalTo: mMenuDividerLineView.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
		mMenuSleepVolumeLabel.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -8).isActive = true
		mMenuSleepVolumeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

		mMenuContainerView.addSubview(mMenuSleepVolumeSlider)
		mMenuSleepVolumeSlider.centerXAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuSleepVolumeSlider.topAnchor.constraint(
			equalTo: mMenuSleepVolumeLabel.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mMenuSleepVolumeSlider.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mMenuSleepVolumeSlider.heightAnchor.constraint(equalToConstant: 50).isActive = true
		sleepSliderDidChange(sender: mMenuSleepVolumeSlider)

		// Countdown Controls StackView
		mMenuContainerView.addSubview(mCountdownPlaylistExplanationLabel)
		mCountdownPlaylistExplanationLabel.topAnchor.constraint(
			equalTo: mMenuSleepVolumeSlider.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mCountdownPlaylistExplanationLabel.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mCountdownPlaylistExplanationLabel.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -8).isActive = true
		mCountdownPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

		mMenuContainerView.addSubview(mCountdownPlaylistsCollectionView)
		mCountdownPlaylistsCollectionView.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mCountdownPlaylistsCollectionView.topAnchor.constraint(
			equalTo: mCountdownPlaylistExplanationLabel.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mCountdownPlaylistsCollectionView.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mCountdownPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		} else {
			mCountdownPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		}

		mMenuContainerView.addSubview(mMenuAlarmVolumeLabel)
		mMenuAlarmVolumeLabel.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mMenuAlarmVolumeLabel.topAnchor.constraint(
			equalTo: mCountdownPlaylistsCollectionView.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
		mMenuAlarmVolumeLabel.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -8).isActive = true
		mMenuAlarmVolumeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

		mMenuContainerView.addSubview(mMenuAlarmVolumeSlider)
		mMenuAlarmVolumeSlider.centerXAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuAlarmVolumeSlider.topAnchor.constraint(
			equalTo: mMenuAlarmVolumeLabel.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mMenuAlarmVolumeSlider.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mMenuAlarmVolumeSlider.heightAnchor.constraint(equalToConstant: 50).isActive = true
		alarmSliderDidChange(sender: mMenuAlarmVolumeSlider)

		// Alarm Controls StackView
		mMenuContainerView.addSubview(mAlarmPlaylistExplanationLabel)
		mAlarmPlaylistExplanationLabel.topAnchor.constraint(
			equalTo: mMenuAlarmVolumeSlider.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mAlarmPlaylistExplanationLabel.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mAlarmPlaylistExplanationLabel.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -8).isActive = true
		mAlarmPlaylistExplanationLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

		mMenuContainerView.addSubview(mAlarmPlaylistsCollectionView)
		mAlarmPlaylistsCollectionView.leftAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
		mAlarmPlaylistsCollectionView.topAnchor.constraint(
			equalTo: mAlarmPlaylistExplanationLabel.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		mAlarmPlaylistsCollectionView.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mAlarmPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		} else {
			mAlarmPlaylistsCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
			
		}

		mMenuScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(
			target: self, action: #selector(menuEdgeScreenPanned(sender:)))
		mMenuScreenEdgePanGestureRecognizer.edges = UIRectEdge.left
		view.addGestureRecognizer(mMenuScreenEdgePanGestureRecognizer)

		mMenuContainerView.addSubview(mMenuViewPreviousSessionButton)
		mMenuViewPreviousSessionButton.centerXAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mMenuViewPreviousSessionButton.topAnchor.constraint(
			equalTo: mAlarmPlaylistsCollectionView.bottomAnchor, constant: 16).isActive = true
		mMenuViewPreviousSessionButton.widthAnchor.constraint(
			equalTo: mMenuContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mMenuViewPreviousSessionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	// Set system volume to kCountdownStartVolume and
	// initialize sountdown steps based on
	// kCountdownStartVolume/kCountdownEndVolume delta
	fileprivate func initializeCountdownVolume() {
		print("countdown volume: \(mCountdownVolume)")
		AudioPlayer.shared.setVolume(new_vol: 0.0)
		AudioPlayer.shared.fadeToVolumeOverDuration(
			new_vol: mCountdownVolume, duration: 5.0)
	}
	
	fileprivate func initializeAlarmVolume() {
		print("alarm wake volume: \(mAlarmWakeVolume)")
		AudioPlayer.shared.setVolume(new_vol: 0.0)
		AudioPlayer.shared.fadeToVolumeOverDuration(
			new_vol: mAlarmWakeVolume, duration: 60.0)
	}
	
	/***
	* Delegate Methods
	*/
	
	// Set both Countdown and Alarm Playlists count
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return AudioPlayer.shared.getTrackNames().count
	}
	
	// Set up both Countdown and Alarm Playlist cells
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let playlistCell: PlaylistCell = collectionView.dequeueReusableCell(
			withReuseIdentifier: "PlaylistCellID", for: indexPath) as! PlaylistCell
		playlistCell.mPlaylistLabel.text =
			AudioPlayer.shared.getTrackNames()[indexPath.item]
		return playlistCell
	}
	
	// Handle collection view selections, handling both countdown and alarm
	// collection views and differentiating based on UICollectionView
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index: Int = indexPath.item
		let selectedTrackName: String = AudioPlayer.shared.getTrackNames()[index]
		if collectionView == mCountdownPlaylistsCollectionView {
			mCountdownAudioFilename = AudioPlayer.shared.getTrackFilename(name: selectedTrackName)
			mCountdownPlaylistChosenLabel.text = "Track: \(selectedTrackName)"
			mCountdownPlaylistChosenInfoLabel.text = "Playlist duration: tbd"
			print("countdown collectionview \(selectedTrackName)")
		} else {
			mAlarmAudioFilename = AudioPlayer.shared.getTrackFilename(name: selectedTrackName)
			mAlarmPlaylistChosenLabel.text = "Track: \(selectedTrackName)"
			mAlarmPlaylistChosenInfoLabel.text = "Playlist duration: tbd"
			print("alarm collectionview \(selectedTrackName)")
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
			timeInterval: 1.0, target: self,
			selector: #selector(twinkleStar(sender:)),
			userInfo: ["number": 1], repeats: true)
		mStarTimer2 = Timer.scheduledTimer(
			timeInterval: 1.25, target: self,
			selector: #selector(twinkleStar(sender:)),
			userInfo: ["number": 2], repeats: true)
		mStarTimer3 = Timer.scheduledTimer(
			timeInterval: 1.5, target: self,
			selector: #selector(twinkleStar(sender:)),
			userInfo: ["number": 3], repeats: true)
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
					starPoint = try SomnusUtils.shared.generateRandomPositionWithBounds(
						widthBounds: widthBounds, heightBounds: heightBounds1)
				} else {
					starPoint = try SomnusUtils.shared.generateRandomPositionWithBounds(
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
			mCountdownStr = SomnusUtils.shared.formatSeconds(seconds: Double(mCountdownTimeInterval!))
		} else if sender.datePickerMode == UIDatePicker.Mode.time {
			// editing alarm time
			mAlarmDate = sender.date
			mAlarmCalendar = sender.calendar
			mAlarmStr = SomnusUtils.shared.formatDate(date: mAlarmDate!, calendar: mAlarmCalendar!)
			print("\(mAlarmStr)")
			print("\(String(describing: mAlarmDate?.localizedDescription))")
		} else {
			print("datepicker mode not supported")
		}
	}
	
	// Start Comnus Session Button target
	@objc func startSomnusSession() {
		print("startSomnusSession")
		print("\(mCountdownStr)")
		print("\(mAlarmStr)")
		print("notifications granted: \(SomnusUtils.shared.checkNotificationCenterPermissions())")
		// Make sure timers are cleared
		mCountdownTimer?.invalidate()
		mAlarmTimer?.invalidate()
		mAlarmWakeTimer?.invalidate()
		mSnoozeTimer?.invalidate()
		if !AudioRecorder.shared.isRecordingAuthorized() {
			mRecordingImageView.isHidden = true
			mRecordingLabel.isHidden = true
		}
		// Initialize session values
		// Reset Alarm Span Time Interval
		mAlarmWakeTimeInterval = 600.0
		// Safely retrieve optional members
		mCountdownTimeInterval = mCountdownDatePicker.countDownDuration
		guard let countdownTimeInterval: TimeInterval = mCountdownTimeInterval else {
			print("countdown time interval nil")
			return
		}
		mAlarmDate = mAlarmDatePicker.date
		guard var alarmDate: Date = mAlarmDate else {
			print("alarm date nil")
			return
		}
		mAlarmCalendar = mAlarmDatePicker.calendar
		guard let alarmCal: Calendar = mAlarmCalendar else {
			print("alarm calendar nil")
			return
		}
		// Adjust date if it is tomorrow, earlier than now.
		alarmDate = SomnusUtils.shared.getCorrectDate(date: alarmDate, calendar: alarmCal)
		// Save date for data preview
		mNowDate = Date()

		// Ensure audio file is selected/valid, otherwise present alert
		if mCountdownAudioFilename == nil {
			presentPlaylistError(errorType: PlaylistError.CountdownPlaylistNotChosen)
			return
		}
		if mAlarmAudioFilename == nil {
			presentPlaylistError(errorType: PlaylistError.AlarmPlaylistNotChosen)
			return
		}
		// Format countdown and alarm values to present in Somnus Session
		mCountdownLabel.text = SomnusUtils.shared.formatSeconds(
			seconds: Double(countdownTimeInterval))
		mAlarmLabel.text = SomnusUtils.shared.formatDate(
			date: alarmDate, calendar: alarmCal)
		// Start the selected track with audioplayer
		mDispatchBackgroundQueue.async {
			// Remove current audio files in documents directory
			SomnusUtils.shared.removeFilesFromDirectory(
				url: SomnusUtils.shared.getDocumentsDirectory())
			// Start Audio Recording for background execution
			AudioRecorder.shared.initRecorder(filename: "session")
			AudioRecorder.shared.startRecording(timeOffset: nil)
			// Start Audio Player
			AudioPlayer.shared.playAudioPlayer(
				filename: self.mCountdownAudioFilename!, ext: "m4a")
			// Set system volume to kCountdownStartVolume
			self.initializeCountdownVolume()
			
			DispatchQueue.main.async {
				UIView.animate(withDuration: 1.0, animations: {
					self.mNowPlayingTrackLabel.alpha = 1
					self.mNowPlayingArtistLabel.alpha = 1
					self.mNowPlayingAlbumImage.alpha = 1
				})
			}
		}
		// Disable menu gesture during Somnus Session
		mMenuScreenEdgePanGestureRecognizer.isEnabled = false
		// Update session state
		SomnusUtils.shared.mSomnusSessionState = .active
		// Animate into the session
		UIView.animate(withDuration: 0.5, animations: {
			self.mSetUpContainerView.alpha = 0.0
			self.mStartSomnusSessionButton.alpha = 0.0
			self.mSomnusSessionContainerView.alpha = 1.0
			self.mStopSomnusSessionButton.alpha = 1.0
			self.mMenuButton.alpha = 0.0
		}) { (bool) in
			print("start countdown animation done")
			self.mCountdownTimer?.invalidate()
			self.mCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
												   target: self,
												   selector: #selector(self.updateCountdown),
												   userInfo: nil, repeats: true)
			// Initialize the alarm timer
			self.startAlarmTimer(alarmDate: alarmDate, calendar: alarmCal)
		}
	}
	
	// Stop Somnus session. Invalidate timers, stop mediaplayer,
	// and animate back to initialization options
	@objc func stopSomnusSession() {
		print("stopSomnusSession")
		mCountdownTimer?.invalidate()
		print("countdown timer valid: \(String(describing: mCountdownTimer?.isValid))")
		mAlarmWakeTimer?.invalidate()
		print("alarmwake timer valid: \(String(describing: mAlarmWakeTimer?.isValid))")
		mSnoozeTimer?.invalidate()
		print("snooze timer valid: \(String(describing: mSnoozeTimer?.isValid))")
		mAlarmTimer?.invalidate()
		print("alarm timer valid: \(String(describing: mAlarmTimer?.isValid))")
		
		// Save data for preview
		let stopNowDate: Date = Date()
		if let dateDifferenceInSeconds: Int =
			Calendar.current.dateComponents([.second], from: mNowDate, to: stopNowDate).second {
			UserDefaults.standard.set(dateDifferenceInSeconds, forKey: "PreviousSessionDuratonSeconds")
		} else {
			UserDefaults.standard.set(0, forKey: "PreviousSessionDuratonSeconds")
		}
		UserDefaults.standard.set(mSnoozeCount, forKey: "PreviousSessionSnoozeCount")
		UserDefaults.standard.set(mNowDate, forKey: "PreviousSessionDate")
		
		SomnusUtils.shared.mSomnusSessionState = .inactive
		mMenuScreenEdgePanGestureRecognizer.isEnabled = true
		
		// Audio player checks if already playing
		AudioPlayer.shared.stopAudioPlayer()
		// Stop AudioRecorder
		AudioRecorder.shared.stopRecording()
		
		if let documentsURLs: Array<URL> = SomnusUtils.shared.getFilesInDocumentsDirectory() {
			print("urls: \(documentsURLs)")
		}
		
		UIView.animate(withDuration: 0.5, animations: {
			self.mSetUpContainerView.alpha = 1.0
			self.mStartSomnusSessionButton.alpha = 1.0
			self.mSomnusSessionContainerView.alpha = 0.0
			self.mStopSomnusSessionButton.alpha = 0.0
			self.mSnoozeSomnusSessionButton.alpha = 0.0
			self.mSnoozeLabel.alpha = 0.0
			self.mMenuButton.alpha = 1.0
		}) { (bool) in
			print("alarm animation done")
		}
		print("interval: \(mAlarmWakeTimeInterval)")
	}
	
	// Snooze Somnus Session, add time to alarm, pause media playback,
	// start snooze timer, and update UI.
	@objc func snoozeSomnusSession() {
		print("snoozeSomnusSession")
		// Only progress of not already snoozing
		if SomnusUtils.shared.mSomnusSessionState == .snoozed {
			return
		}
		// Make sure snooze is invalid
		mSnoozeTimer?.invalidate()
		// Update session state
		SomnusUtils.shared.mSomnusSessionState = .snoozed
		// Reset snooze interval
		mSnoozeTimeInterval = 300.0
		// Add additional time to alarm to accomodate snooze time
		mAlarmWakeTimeInterval += 300.0
		// Stop alarm sound and
		// Restart mic recording
		DispatchQueue.global(qos: .userInteractive).async {
			self.mSnoozeCount += 1
			AudioPlayer.shared.pauseAudioPlayer()
			AudioPlayer.shared.setVolume(new_vol: 0.0)
		}
		
		UIView.animate(withDuration: 0.5) {
			self.mSnoozeLabel.alpha = 1.0
		}
		mSnoozeTimer = Timer.scheduledTimer(timeInterval: 1.0,
											target: self,
											selector: #selector(self.updateSnooze),
											userInfo: nil, repeats: true)
	}
	
	// Menu Gesture and Button methods
	
	@objc func menuEdgeScreenPanned(sender: UIScreenEdgePanGestureRecognizer) {
		// retrieve the current state of the gesture
		if sender.state == UIGestureRecognizer.State.began {
			// if the user has just started dragging, make sure view for dimming effect is hidden well
			mMenuBackgroundView.isHidden = false
			mMenuBackgroundView.alpha = 0
		} else if (sender.state == UIGestureRecognizer.State.changed) {
			// retrieve the amount mMenuView has been dragged
			let translationX = sender.translation(in: sender.view).x
			if -mMenuWidthConstraint.constant + translationX > 0 {
				// mMenuView fully dragged out
				mMenuLeftConstraint.constant = 0
				mMenuBackgroundView.alpha = kMaxMenuBackgroundAlpha
			} else if translationX < 0 {
				// mMenuView fully dragged in
				mMenuLeftConstraint.constant = -mMenuWidthConstraint.constant
				mMenuBackgroundView.alpha = 0
			} else {
				// mMenuView is being dragged somewhere between min and max amount
				mMenuLeftConstraint.constant = -mMenuWidthConstraint.constant + translationX
				let ratio = translationX / mMenuWidthConstraint.constant
				let alphaValue = ratio * kMaxMenuBackgroundAlpha
				mMenuBackgroundView.alpha = alphaValue
			}
		} else {
			// if the menu was dragged less than half of it's width, close it. Otherwise, open it.
			if mMenuLeftConstraint.constant < -mMenuWidthConstraint.constant / 2 {
				self.hideMenu()
			} else {
				self.openMenu()
			}
		}
	}
	
	@objc func menuBackgroundTapped(sender: UITapGestureRecognizer) {
		//print("Menu background tapped")
		self.hideMenu()
	}
	
	@objc func menuBackgroundPanned(sender: UIPanGestureRecognizer) {
		//print("menu background panned")
		// retrieve the current state of the gesture
		if sender.state == UIGestureRecognizer.State.began {
			// no need to do anything
		} else if sender.state == UIGestureRecognizer.State.changed {
			// retrieve the amount viewMenu has been dragged
			let translationX = sender.translation(in: sender.view).x
			if translationX > 0 {
				// viewMenu fully dragged out
				mMenuLeftConstraint.constant = 0
				mMenuBackgroundView.alpha = kMaxMenuBackgroundAlpha
			} else if translationX < -mMenuWidthConstraint.constant {
				// viewMenu fully dragged in
				mMenuLeftConstraint.constant = -mMenuWidthConstraint.constant
				mMenuBackgroundView.alpha = 0
			} else {
				// it's being dragged somewhere between min and max amount
				mMenuLeftConstraint.constant = translationX
				let ratio = (mMenuWidthConstraint.constant + translationX) / mMenuWidthConstraint.constant
				let alphaValue = ratio * kMaxMenuBackgroundAlpha
				mMenuBackgroundView.alpha = alphaValue
			}
		} else {
			// if the drag was less than half of it's width, close it. Otherwise, open it.
			if mMenuLeftConstraint.constant < -mMenuWidthConstraint.constant / 2 {
				hideMenu()
			} else {
				openMenu()
			}
		}
	}
	
	fileprivate func openMenu() {
		// when menu is opened, it's left constraint should be 0
		mMenuLeftConstraint.constant = 0
		// view for dimming effect should also be shown
		mMenuBackgroundView.isHidden = false
		// animate opening of the menu - including opacity value
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
			self.mMenuBackgroundView.alpha = self.kMaxMenuBackgroundAlpha
		}, completion: { (complete) in
			// disable the screen edge pan gesture when menu is fully opened
			self.mMenuScreenEdgePanGestureRecognizer.isEnabled = false
		})
	}
	
	fileprivate func hideMenu() {
		// when menu is closed, it's left constraint should be of
		// value that allows it to be completely hidden to the left
		// of the screen - which is negative value of it's width.
		if (!AudioRecorder.shared.isRecordingAuthorized()) {
			AudioRecorder.shared.requestRecordAuthorization()
		}
		mMenuLeftConstraint.constant = -mMenuWidthConstraint.constant
		// animate closing of the menu - including opacity value
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
			self.mMenuBackgroundView.alpha = 0
		}, completion: { (complete) in
			// reenable the screen edge pan gesture so we can
			// detect it next time
			self.mMenuScreenEdgePanGestureRecognizer.isEnabled = true
			// hide the view for dimming effect so it wont interrupt
			// touches for views underneath it
			self.mMenuBackgroundView.isHidden = true
		})
	}
	
	@objc func menuButtonPressed() {
		openMenu()
	}
	
	@objc func sleepSliderDidChange(sender: UISlider) {
		let sliderVal: Int = Int((sender.value * 100).rounded())
		mMenuSleepVolumeLabel.text = "Sleep Volume: \(sliderVal)%"
		mCountdownVolume = sender.value
	}
	
	@objc func alarmSliderDidChange(sender: UISlider) {
		let sliderVal: Int = Int((sender.value * 100).rounded())
		mMenuAlarmVolumeLabel.text = "Alarm Volume: \(sliderVal)%"
		mAlarmWakeVolume = sender.value
	}
	
	/***
	* Helper functions
	*/
	
	fileprivate func startAlarmTimer(alarmDate: Date, calendar: Calendar) {
		print("starting alarm")
		let dateComponents: DateComponents =
			calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate)
		let date: Date = calendar.date(from: dateComponents)!
		print("date: \(date.localizedDescription)")
		print("mic recording: \(AudioRecorder.shared.audioRecorderIsrecording())")
		mAlarmTimer = Timer.init(
			fireAt: date, interval: 0,
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
		UIView.animate(withDuration: 0.5, animations: {
			self.mSnoozeSomnusSessionButton.alpha = 1.0
		})
		// Stop Audio Player
		AudioPlayer.shared.stopAudioPlayer()
		// Send notification
		SomnusUtils.shared.pushNotification(
			title: "Somnus", body: "Alarm time has been reached")
		// Set correct state
		SomnusUtils.shared.mSomnusSessionState = .alarmWake
		
		// Set system volum to alarm volume
		initializeAlarmVolume()
		
		// Start Audio Player
		AudioPlayer.shared.playAudioPlayer(
			filename: mAlarmAudioFilename!, ext: "m4a")
		
		mAlarmWakeTimer = Timer.scheduledTimer(timeInterval: 1.0,
											   target: self,
											   selector: #selector(self.updateAlarmWake),
											   userInfo: nil, repeats: true)
		print("ALARM ALARM")
	}
	
	// UI Update Targets
	
	// Countdown timer target, update the current time interval
	// and format/publish new interval to the UI
	@objc func updateCountdown() {
		print("update countdown")
		// Stop countdown operations once interval
		// has reached zero.
		if mCountdownTimeInterval == 0.0 {
			print("sleep playback done")
			mCountdownTimer?.invalidate()
			// Audio player checks if already playing
			AudioPlayer.shared.stopAudioPlayer()
			return
		}
		if mCountdownTimeInterval == 30.0 {
			AudioPlayer.shared.fadeToVolumeOverDuration(
				new_vol: 0.0, duration: 30.0)
		}
		// Otherwise continue to decrement interval,
		// and update UI.
		mCountdownTimeInterval! -= 1.0
		mCountdownStr = SomnusUtils.shared.formatSeconds(
				seconds: Double(mCountdownTimeInterval!))
		mCountdownLabel.text = mCountdownStr
		print("countdown interval: \(mCountdownTimeInterval!)")
		print("mic recording: \(AudioRecorder.shared.audioRecorderIsrecording())")
		print("audio playing: \(AudioPlayer.shared.audioPlayerIsPlaying())")
		print("somnus session state: \(SomnusUtils.shared.mSomnusSessionState)")
		print("audio player volume: \(AudioPlayer.shared.getVolume())")
	}
	
	@objc func updateAlarmWake() {
		// Stop Somnus session if end of alarm time interval
		// reached, also stop on voice command result.
		if mAlarmWakeTimeInterval == 0.0 {
			print("alarm done")
			stopSomnusSession()
			return
		}
		// Continue to decrement interval
		mAlarmWakeTimeInterval -= 1.0
		print("alarm interval: \(mAlarmWakeTimeInterval)")
		print("mic recording: \(AudioRecorder.shared.audioRecorderIsrecording())")
		print("somnus session state: \(SomnusUtils.shared.mSomnusSessionState)")
		print("audio player volume: \(AudioPlayer.shared.getVolume())")
		print("audio playing: \(AudioPlayer.shared.audioPlayerIsPlaying())")
	}
	
	// Snoozing update method
	@objc func updateSnooze() {
		if mSnoozeTimeInterval == 0.0 {
			// Push snooze notification
			SomnusUtils.shared.pushNotification(
				title: "Somnus", body: "Snooze has ended")
			// Return alarm to alarm state upon the ending of the
			// snoozing state, start alarm sound again
			AudioPlayer.shared.playAudioPlayerFromPause()
			AudioPlayer.shared.fadeToVolumeOverDuration(new_vol: mAlarmWakeVolume, duration: 5.0)
			SomnusUtils.shared.mSomnusSessionState = .alarmWake
			mSnoozeTimer?.invalidate()
			UIView.animate(withDuration: 0.5) {
				self.mSnoozeLabel.alpha = 0.0
			}
			return
		}
		// Else, decrement time interval as normal and
		// update UI
		mSnoozeTimeInterval -= 1.0
		mSnoozeLabel.text = SomnusUtils.shared.formatSeconds(
			seconds: Double(mSnoozeTimeInterval))
		print("snooze time: \(mSnoozeTimeInterval)")
		print("audio player volume: \(AudioPlayer.shared.getVolume())")
	}
	
	@objc func viewPreviousSessionData() {
		print("viewPreviousSessionData")
		let previousSessionPreviewVC: PreviousSessionPreviewViewController =
			PreviousSessionPreviewViewController()
		self.navigationController?.pushViewController(previousSessionPreviewVC, animated: true)
	}

	/***
	* Error functions
	**/
	
	public func presentPlaylistError(errorType: PlaylistError) {
		var alert: UIAlertController?
		switch errorType {
		case PlaylistError.CountdownPlaylistNotChosen:
			alert = UIAlertController(
				title: "",
				message: "Sleep track not chosen",
				preferredStyle: UIAlertController.Style.alert)
		case PlaylistError.AlarmPlaylistNotChosen:
			alert = UIAlertController(
				title: "",
				message: "Alarm track not chosen",
				preferredStyle: UIAlertController.Style.alert)
		default:
			alert = UIAlertController(
				title: "",
				message: "Track error",
				preferredStyle: UIAlertController.Style.alert)
		}
		alert!.addAction(UIAlertAction(title: "OK",
									   style: UIAlertAction.Style.default,
									   handler: nil))
		self.present(alert!, animated: true, completion: nil)
	}
	
	public func presentPermissionsError(errorType: PermissionsError) {
		var alert: UIAlertController?
		switch errorType {
		case PermissionsError.MissingMediaPermissions:
			alert = UIAlertController(
				title: "Permissions Missing",
				message: "Somnus doesn't have acccess to your Music library. " +
				"Please go to Settings->Somnus->Media & Apple Music, and enable Somnus to access playlists.",
				preferredStyle: UIAlertController.Style.alert)
		case PermissionsError.MissingNotificationsPermissions:
			alert = UIAlertController(
				title: "Permissions Missing",
				message: "Somnus doesn't have permission to send notifications. Please go to " +
				"Settings->Somnus->Allow Notifications, and enable Somnus to wake your phone with the the alarm.",
				preferredStyle: UIAlertController.Style.alert)
		}
		alert!.addAction(UIAlertAction(title: "OK",
									  style: UIAlertAction.Style.default,
									  handler: nil))
		self.present(alert!, animated: true, completion: nil)
	}
	
	/***
	* View Controller Properties
	*/
	
	fileprivate let kMaxMenuBackgroundAlpha: CGFloat = 0.75
	fileprivate var mSnoozeCount: Int = 0
	fileprivate var mNowDate: Date = Date()
	
	fileprivate var mCountdownVolume: Float = 0.50
	fileprivate var mCountdownAudioFilename: String?
	fileprivate var mCountdownStr: String = "00:00:00"
	fileprivate var mCountdownTimeInterval: TimeInterval?
	fileprivate var mCountdownTimer: Timer?

	
	fileprivate var mAlarmWakeVolume: Float = 0.80
	fileprivate var mAlarmAudioFilename: String?
	fileprivate var mAlarmStr: String = "00:00 AM"
	fileprivate var mAlarmTimer: Timer?
	fileprivate var mAlarmDate: Date?
	fileprivate var mAlarmCalendar: Calendar?
	
	fileprivate var mAlarmWakeTimeInterval: Double = 600.0
	fileprivate var mAlarmWakeTimer: Timer?
	
	fileprivate var mSnoozeTimeInterval: Double = 300.0
	fileprivate var mSnoozeTimer: Timer?
	
	fileprivate let mDispatchBackgroundQueue =
		DispatchQueue(label: "DispatchBackgroundQueue", qos: .background)
	
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
	
	/***
	* User Interface Widgets
	*/
	
	fileprivate let mMiddleLineView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	fileprivate let mMoonImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "moon"))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mMenuButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
		button.setImage(UIImage(named: "menu"), for: UIControl.State.normal)
		button.backgroundColor = UIColor.clear
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
		button.addTarget(self, action: #selector(menuButtonPressed),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mMenuView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.white
		view.isUserInteractionEnabled = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mMenuContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.isUserInteractionEnabled = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate var mMenuLeftConstraint: NSLayoutConstraint!
	fileprivate var mMenuWidthConstraint: NSLayoutConstraint!
	fileprivate var mMenuScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
	fileprivate var mMenuBackgroundTapGestureRecognizer: UITapGestureRecognizer!
	fileprivate var mMenuBackgroundPanGestureRecognizer: UIPanGestureRecognizer!
	
	fileprivate let mMenuBackgroundView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.black
		view.isUserInteractionEnabled = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mMenuOptionsLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Options"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 24)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mMenuDividerLineView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mMenuSleepVolumeLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Sleep Volume: 100%"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mMenuSleepVolumeSlider: UISlider = {
		let slider: UISlider = UISlider()
		slider.isContinuous = true
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		slider.setValue(0.5, animated: false)
		slider.addTarget(self,
						 action: #selector(sleepSliderDidChange(sender:)),
						 for: UIControl.Event.valueChanged)
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
	fileprivate let mMenuAlarmVolumeLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Alarm Volume: 100%"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mMenuAlarmVolumeSlider: UISlider = {
		let slider: UISlider = UISlider()
		slider.isContinuous = true
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		slider.setValue(0.85, animated: false)
		slider.addTarget(self,
						 action: #selector(alarmSliderDidChange(sender:)),
						 for: UIControl.Event.valueChanged)
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
	fileprivate let mMenuViewPreviousSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.setTitle("previous session", for: UIControl.State.normal)
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.addTarget(self, action: #selector(viewPreviousSessionData),
						 for: UIControl.Event.touchUpInside)
		button.setTitleColor(UIColor.black, for: UIControl.State.normal)
		button.backgroundColor = UIColor.clear
		button.layer.cornerRadius = 5
		button.clipsToBounds = true
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 2
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mSetUpContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mCountdownExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Sleep playback duration:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 20)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mCountdownDatePicker: UIDatePicker = {
		let dp: UIDatePicker = UIDatePicker()
		dp.setValue(UIColor.white, forKeyPath: "textColor")
		dp.isUserInteractionEnabled = true
		dp.backgroundColor = UIColor.clear
		dp.datePickerMode = UIDatePicker.Mode.countDownTimer
		dp.addTarget(self, action: #selector(datePickerChanged(sender:)),
					 for: UIControl.Event.valueChanged)
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()
	
	fileprivate let mCountdownPlaylistChosenLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Track: Not Chosen"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.alpha = 0.6
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mCountdownPlaylistChosenInfoLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Track Duration: None"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.alpha = 0.6
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mCountdownPlaylistExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Sleep Track:"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	public let mCountdownPlaylistsCollectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout  = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
		layout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
		if SomnusUtils.shared.hasSmallerScreen() {
			layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		} else {
			layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
		}
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = UIColor.clear
		collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCellID")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	fileprivate let mAlarmExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Alarm time:"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 20)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmDatePicker: UIDatePicker = {
		let dp: UIDatePicker = UIDatePicker()
		dp.setValue(UIColor.white, forKeyPath: "textColor")
		dp.isUserInteractionEnabled = true
		dp.backgroundColor = UIColor.clear
		dp.datePickerMode = UIDatePicker.Mode.time
		dp.addTarget(self, action: #selector(datePickerChanged(sender:)),
					 for: UIControl.Event.valueChanged)
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()
	
	fileprivate let mAlarmPlaylistChosenLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Track: Not Chosen"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.alpha = 0.6
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmPlaylistChosenInfoLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Track Duration: None"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.alpha = 0.6
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmPlaylistExplanationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Alarm Track:"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.left
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmPlaylistsCollectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout  = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
		layout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
		if SomnusUtils.shared.hasSmallerScreen() {
			layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		} else {
			layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
		}
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = UIColor.clear
		collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCellID")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	fileprivate let mStartSomnusSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.clear
		button.tintColor = UIColor.white
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.borderWidth = 2
		button.setTitle("start", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(startSomnusSession),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mSomnusSessionContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mCountdownLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "00:00:00"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 56)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mNowPlayingContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	fileprivate let mNowPlayingAlbumImage: UIImageView = {
		let view: UIImageView = UIImageView()
		view.backgroundColor = UIColor.black
		view.alpha = 0
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
		label.text = ""
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 14)
		label.alpha = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mNowPlayingArtistLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = ""
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 14)
		label.alpha = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mAlarmLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "00:00 AM"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
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
	
	fileprivate let mSnoozeLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "00:00:00"
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 12)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mSnoozeSomnusSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.clear
		button.tintColor = UIColor.white
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.layer.borderWidth = 2
		button.layer.borderColor = UIColor.white.cgColor
		button.setTitle("snooze", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(snoozeSomnusSession),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mStopSomnusSessionButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.clear
		button.tintColor = UIColor.white
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 35
		button.clipsToBounds = true
		button.layer.borderWidth = 2
		button.layer.borderColor = UIColor.white.cgColor
		button.setTitle("stop", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(stopSomnusSession),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	fileprivate let mRecordingImageView: UIImageView = {
		let view: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let micImage = UIImage(named: "microphone");
		let tintedImage = micImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		view.image = tintedImage
		view.tintColor = UIColor.white
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mRecordingLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Recording ..."
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 12)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate var mCloudOneImageView: UIImageView!
	fileprivate var mCloudTwoImageView: UIImageView!
	fileprivate var mCloudThreeImageView: UIImageView!
	fileprivate let kCloudOneOrigin: CGRect = CGRect(x: -1000, y: 450, width: 115, height: 60)
	fileprivate let kCloudTwoOrigin: CGRect = CGRect(x: -1000, y: 400, width: 130, height: 90)
	fileprivate let kCloudThreeOrigin: CGRect = CGRect(x: -1000, y: 500, width: 110, height: 70)
	fileprivate let kCloudOneTime: Int = 10
	fileprivate let kCloudTwoTime: Int = 15
	fileprivate let kCloudThreeTime: Int = 20
	fileprivate let kMinCloudBound: CGFloat = SCREENBOUNDS.height / 2.0
	fileprivate let kMaxCloudBound: CGFloat = (SCREENBOUNDS.height / 2.0) + 100.0
}
