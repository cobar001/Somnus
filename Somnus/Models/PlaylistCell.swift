//
//  PlaylistCell.swift
//  Somnus
//
//  Created by Chris Cobar on 1/8/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit

class PlaylistCell: UICollectionViewCell {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setUpUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected {
				self.mPlaylistLabel.backgroundColor = UIColor.black
				self.mPlaylistLabel.textColor = UIColor.white
			}
			else {
				self.mPlaylistLabel.backgroundColor = UIColor.clear
				self.mPlaylistLabel.textColor = UIColor.black
			}
		}
	}
	
	func setUpUI() {
		contentView.addSubview(mPlaylistLabel)
		mPlaylistLabel.centerXAnchor.constraint(
			equalTo: contentView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPlaylistLabel.centerYAnchor.constraint(
			equalTo: contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mPlaylistLabel.widthAnchor.constraint(
			equalTo: contentView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPlaylistLabel.heightAnchor.constraint(
			equalTo: contentView.safeAreaLayoutGuide.heightAnchor).isActive = true
	}
	
	let mPlaylistLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "playlist name"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
}
