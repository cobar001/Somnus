//
//  WelcomePageThreeViewController.swift
//  Somnus
//
//  Created by Chris Cobar on 1/24/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

class WelcomePageThreeViewController: UIViewController {

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
		
	}
	
	fileprivate let mImageView: UIImageView = {
		let view: UIImageView = UIImageView(image: UIImage(named: "SomnusOnBoardingPage3"))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
}
