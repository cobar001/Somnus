//
//  WelcomePageFourViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/24/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

class WelcomePageFourViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = UIColor.white
		setUpUI()
    }
	
	func setUpUI() {
		view.addSubview(mImageView)
		mImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		if SomnusUtils.shared.kHasSmallerScreen {
			mImageView.widthAnchor.constraint(equalToConstant: 621 * 0.49).isActive = true
			mImageView.heightAnchor.constraint(equalToConstant: 1344 * 0.49).isActive = true
		} else {
			mImageView.widthAnchor.constraint(equalToConstant: 621 * 0.6).isActive = true
			mImageView.heightAnchor.constraint(equalToConstant: 1344 * 0.6).isActive = true
		}
		
		view.addSubview(mProgressToAppButton)
		mProgressToAppButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mProgressToAppButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32).isActive = true
		mProgressToAppButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
		mProgressToAppButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	fileprivate let mImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "SomnusOnBoardingPage4"))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate let mProgressToAppButton: UIButton = {
		let button: UIButton = UIButton(type: UIButton.ButtonType.system)
		button.backgroundColor = UIColor.clear
		button.tintColor = UIColor.black
		button.titleLabel?.font = UIFont(name: FONTNAME, size: 18)
		button.titleLabel?.textAlignment = NSTextAlignment.center
		button.layer.cornerRadius = 5
		button.clipsToBounds = true
		button.layer.borderWidth = 2
		button.layer.borderColor = UIColor.black.cgColor
		button.setTitle("begin", for: UIControl.State.normal)
		button.addTarget(self, action: #selector(progressToApp),
						 for: UIControl.Event.touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	@objc func progressToApp() {
		let somnusVC: SomnusViewController = SomnusViewController()
		let indexNavController = UINavigationController(rootViewController: somnusVC)
		present(indexNavController, animated: true, completion: nil)
	}
}
