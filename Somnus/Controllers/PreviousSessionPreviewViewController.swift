//
//  PreviousSessionPreviewViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/29/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit
import FDWaveformView

class PreviousSessionPreviewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setUpUI()
		upDateUIWithInfo()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.isNavigationBarHidden = false
	}
	
	fileprivate func setUpUI() {
		view.backgroundColor = UIColor.white

		view.addSubview(mPreviousSessionContainerView)
		mPreviousSessionContainerView.centerXAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionContainerView.centerYAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mPreviousSessionContainerView.widthAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
		if SomnusUtils.shared.hasSmallerScreen() {
			mPreviousSessionContainerView.heightAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.85).isActive = true
		} else {
			mPreviousSessionContainerView.heightAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.75).isActive = true
		}
		
		mPreviousSessionContainerView.addSubview(mPreviousSessionLabel)
		mPreviousSessionLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionLabel.topAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.topAnchor).isActive = true
		mPreviousSessionLabel.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPreviousSessionLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		mPreviousSessionContainerView.addSubview(mPreviousSessionDateLabel)
		mPreviousSessionDateLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionDateLabel.topAnchor.constraint(
			equalTo: mPreviousSessionLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
		mPreviousSessionDateLabel.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPreviousSessionDateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		mPreviousSessionContainerView.addSubview(mPreviousSessionSleepDurationLabel)
		mPreviousSessionSleepDurationLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionSleepDurationLabel.topAnchor.constraint(
			equalTo: mPreviousSessionDateLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
		mPreviousSessionSleepDurationLabel.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPreviousSessionSleepDurationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		mPreviousSessionContainerView.addSubview(mPreviousSessionSnoozeCountLabel)
		mPreviousSessionSnoozeCountLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionSnoozeCountLabel.topAnchor.constraint(
			equalTo: mPreviousSessionSleepDurationLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
		mPreviousSessionSnoozeCountLabel.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPreviousSessionSnoozeCountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		mPreviousSessionContainerView.addSubview(mPreviousSessionActivityLabel)
		mPreviousSessionActivityLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPreviousSessionActivityLabel.topAnchor.constraint(
			equalTo: mPreviousSessionSnoozeCountLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
		mPreviousSessionActivityLabel.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPreviousSessionActivityLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        mPreviousSessionContainerView.addSubview(mFDWaveFormView)
		mFDWaveFormView.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mFDWaveFormView.topAnchor.constraint(
			equalTo: mPreviousSessionActivityLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
		mFDWaveFormView.widthAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
		mFDWaveFormView.heightAnchor.constraint(equalToConstant: 150).isActive = true
		
		mFDWaveFormView.addSubview(mActivityNotAvailableLabel)
		mActivityNotAvailableLabel.centerXAnchor.constraint(
			equalTo: mFDWaveFormView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mActivityNotAvailableLabel.centerYAnchor.constraint(
			equalTo: mFDWaveFormView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mActivityNotAvailableLabel.sizeToFit()
		mActivityNotAvailableLabel.isHidden = true
		
		mPreviousSessionContainerView.addSubview(mLoadingLabel)
		mLoadingLabel.centerXAnchor.constraint(
			equalTo: mPreviousSessionContainerView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mLoadingLabel.topAnchor.constraint(
			equalTo: mFDWaveFormView.safeAreaLayoutGuide.bottomAnchor).isActive = true
		mLoadingLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
		mLoadingLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	public func upDateUIWithInfo() {
		// query previous session date
		if let previousSessionDate: Date =
			UserDefaults.standard.object(forKey: "PreviousSessionDate") as? Date {
			let formatter = DateFormatter()
			formatter.dateStyle = DateFormatter.Style.long
			mPreviousSessionDateLabel.text = formatter.string(from: previousSessionDate)
		} else {
			mPreviousSessionDateLabel.text = "No Date Recorded"
		}
		// Query previous session sleep duration
		let previousSessionDuration: Int =
			UserDefaults.standard.integer(forKey: "PreviousSessionDuratonSeconds")
		if previousSessionDuration == 0 {
			mPreviousSessionSleepDurationLabel.text = "No Duration Recorded"
		} else {
			mPreviousSessionSleepDurationLabel.text = "Sleep Duration: " +
				"\(SomnusUtils.shared.formatSeconds(seconds: Double(previousSessionDuration)))"
		}
		// Query previous session snoozes
		let previousSessionSnoozes: Int =
			UserDefaults.standard.integer(forKey: "PreviousSessionSnoozeCount")
		mPreviousSessionSnoozeCountLabel.text = "Snooze Count: \(previousSessionSnoozes)"
			// Query transcript
			// for now, there should be only one
		if !AudioRecorder.shared.isRecordingAuthorized() || previousSessionDuration == 0 {
			mActivityNotAvailableLabel.isHidden = false
			mLoadingLabel.isHidden = true
		} else {
			if let previousSessionURLs = SomnusUtils.shared.getFilesInDocumentsDirectory(),
				previousSessionURLs.count == 1 {
				// specify file url
				let fileURL: URL = previousSessionURLs[0]
				print("url: \(fileURL)")
				mFDWaveFormView.audioURL = fileURL
			} else {
				print("waveform failed, no file found")
			}
		}
	}
	
	fileprivate let mPreviousSessionContainerView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.clear
		view.isUserInteractionEnabled = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mPreviousSessionLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Previous Session"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAMEBOLD, size: 36)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mPreviousSessionDateLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Date"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mPreviousSessionSleepDurationLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Sleep Duration: 10"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mPreviousSessionSnoozeCountLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Snoozes: 10"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mPreviousSessionActivityLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Activity:"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
    fileprivate let mFDWaveFormView: FDWaveformView = {
       let fd: FDWaveformView = FDWaveformView()
        fd.doesAllowScrubbing = true
        fd.doesAllowScroll = true
        fd.doesAllowStretch = true
        fd.wavesColor = UIColor.blue
        fd.translatesAutoresizingMaskIntoConstraints = false
        return fd
    }()

	fileprivate let mActivityNotAvailableLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Activity not available"
		label.textColor = UIColor.gray
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	fileprivate let mLoadingLabel: UILabel = {
		let label: UILabel = UILabel()
		label.isUserInteractionEnabled = true
		label.text = "Note: it may take a few seconds to parse longer sessions."
		label.textColor = UIColor.gray
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 2
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
}
