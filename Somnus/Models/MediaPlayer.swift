//
//  MediaPlayer.swift
//  Somnus
//
//  Created by Chris Cobar on 1/27/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

//import Foundation
//import MediaPlayer
//
//class MediaPlayer {
//	
//	static let shared = MediaPlayer()
//	
//	init() {
//		print("media player init")
//		kMPMediaPlayer.repeatMode = MPMusicRepeatMode.all
//		kMPMediaPlayer.shuffleMode = MPMusicShuffleMode.off
//	}
//	
//	public let kMPMediaPlayer: MPMusicPlayerApplicationController =
//		MPMusicPlayerApplicationController.applicationQueuePlayer
//	public var mMPMediaPlaylists: Array<MPMediaPlaylist> = Array<MPMediaPlaylist>()
//
//	public func startPlaylistContinuous(selectedPlaylist: MPMediaPlaylist?) {
//		// Make sure to stop any other media player activity before
//		// beginning anew.
//		if kMPMediaPlayer.playbackState != .stopped {
//			stopPlaylist()
//		}
//		guard let playlist: MPMediaPlaylist = selectedPlaylist else {
//			print("selectedPlaylist nil")
//			return
//		}
//		kMPMediaPlayer.setQueue(with: playlist)
//		kMPMediaPlayer.play()
//		kMPMediaPlayer.beginGeneratingPlaybackNotifications()
//	}
//	
//	public func playFromPausePlaylist() {
//		if kMPMediaPlayer.playbackState == .paused ||
//			kMPMediaPlayer.playbackState == .interrupted {
//			kMPMediaPlayer.play()
//		}
//	}
//	
//	public func pausePlaylist() {
//		kMPMediaPlayer.pause()
//	}
//	
//	public func stopPlaylist() {
//		print("stop playing playlist")
//		kMPMediaPlayer.stop()
//		//kMPMediaPlayer.endGeneratingPlaybackNotifications()
//	}
//	
//	public func checkMediaLibraryPermissions() -> Bool {
//		// Check media player permissions
//		var permissionGranted: Bool = false
//		let mediaLibraryAuthorizationStatus: MPMediaLibraryAuthorizationStatus =
//			MPMediaLibrary.authorizationStatus()
//		if mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.denied ||
//			mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.restricted ||
//			mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.notDetermined {
//			print("media player access denied, restricted, or not determined")
//		} else if mediaLibraryAuthorizationStatus == MPMediaLibraryAuthorizationStatus.authorized {
//			print("media player access authorized")
//			permissionGranted = true
//		} else {
//			print("media player access failed")
//		}
//		return permissionGranted
//	}
//	
//	public func mediaPlayerPlaybackState() -> MPMusicPlaybackState {
//		return kMPMediaPlayer.playbackState
//	}
//}
