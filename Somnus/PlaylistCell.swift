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
				self.mPlaylistLabel.font = UIFont(name: FONTNAMEBOLD, size: 16)
				self.mPlaylistLabel.layer.borderColor = UIColor.black.cgColor
			}
			else {
				self.mPlaylistLabel.font = UIFont(name: FONTNAME, size: 18)
				self.mPlaylistLabel.layer.borderColor = UIColor.clear.cgColor
			}
		}
	}
	
	func setUpUI() {
		contentView.addSubview(mPlaylistLabel)
		mPlaylistLabel.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor).isActive = true
		mPlaylistLabel.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
		mPlaylistLabel.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor).isActive = true
		mPlaylistLabel.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor).isActive = true
	}
	
	let mPlaylistLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "playlist name"
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.textAlignment = NSTextAlignment.center
		label.numberOfLines = 1
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.clipsToBounds = true
		label.layer.borderWidth = 2
		label.layer.borderColor = UIColor.clear.cgColor
		label.layer.cornerRadius = 2
		label.font = UIFont(name: FONTNAME, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
}
