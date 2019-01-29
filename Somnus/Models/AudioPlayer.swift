//
//  AudioPlayer.swift
//  Somnus
//
//  Created by Chris Cobar on 1/27/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
	
	static let shared = AudioPlayer()
	
	override init() {
		print("audio player init")
	}
	
	private let mAudioTrackNames: Array<String> = ["Body", "Psycho"]
	private let mAudioTrackFilenameDictionary: Dictionary<String, String> =
		["Body" : "Body", "Psycho" : "SweetbutPsycho"]
	private let mAudioSession: AVAudioSession = AVAudioSession.sharedInstance()
	private var mAudioPlayer: AVAudioPlayer!
	
	public func playAudioPlayer(filename: String, ext: String) {
		if let fileURL: URL = SomnusUtils.shared.getURLBundlePathForFile(filename: filename, ext: ext) {
			do {
				try mAudioPlayer = AVAudioPlayer(contentsOf: fileURL)
				mAudioPlayer.delegate = self
				mAudioPlayer.numberOfLoops = -1
				mAudioPlayer.play()
			} catch {
				print("error constructing audio player")
			}
		} else {
			print("audio file query error")
		}
	}
	
	public func playAudioPlayer(url: URL) {
		do {
			try mAudioPlayer = AVAudioPlayer(contentsOf: url)
			mAudioPlayer.delegate = self
			mAudioPlayer.numberOfLoops = -1
			mAudioPlayer.play()
		} catch {
			print("error constructing audio player")
		}
	}
	
	public func playAudioPlayerFromPause() {
		if mAudioPlayer != nil && !mAudioPlayer.isPlaying {
			mAudioPlayer.play()
		}
	}
	
	public func pauseAudioPlayer() {
		if mAudioPlayer != nil && mAudioPlayer.isPlaying {
			mAudioPlayer.pause()
			print("audio player paused")
		}
	}
	
	public func stopAudioPlayer() {
		if mAudioPlayer != nil {
			mAudioPlayer.stop()
			mAudioPlayer = nil
			print("audio player stopped")
		}
	}
	
	public func audioPlayerIsPlaying() -> Bool {
		if mAudioPlayer == nil || !mAudioPlayer.isPlaying {
			return false
		}
		return true
	}
	
	public func setVolume(new_vol: Float) {
		print("set new volume: \(new_vol)")
		if mAudioPlayer != nil {
			mAudioPlayer.volume = new_vol
		}
	}
	
	public func fadeToVolumeOverDuration(new_vol: Float, duration: TimeInterval) {
		print("fade to volume: \(new_vol)")
		if mAudioPlayer != nil {
			mAudioPlayer.setVolume(new_vol, fadeDuration: duration)
		}
	}
	
	public func getVolume() -> Float {
		if mAudioPlayer != nil {
			return mAudioPlayer.volume
		}
		return -1.0
	}
	
	public func getMusicLibraryPlaylists() -> Array<MPMediaPlaylist> {
		let myPlaylistQuery: MPMediaQuery = MPMediaQuery.playlists()
		var musicPlayerPlaylists: Array<MPMediaPlaylist> = Array<MPMediaPlaylist>()
		guard let playlists = myPlaylistQuery.collections else {
			return musicPlayerPlaylists
		}
		for playlist in playlists {
			guard let p = playlist as? MPMediaPlaylist else {
				continue
			}
			musicPlayerPlaylists.append(p)
		}
		return musicPlayerPlaylists
	}
	
	public func getSongsFromPlaylist(playlist: MPMediaPlaylist) -> Array<MPMediaItem> {
		var playlistMediaItems: Array<MPMediaItem> = Array<MPMediaItem>()
		let songs = playlist.items
		for song in songs {
			let songTitle: String? = song.title
			playlistMediaItems.append(song)
			print("\t\t", songTitle!)
		}
		return playlistMediaItems
	}
	
	public func getTrackFilename(name: String) -> String? {
		return mAudioTrackFilenameDictionary[name]
	}
	
	public func getTrackNames() -> Array<String> {
		return mAudioTrackNames
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if !flag {
			print("playing failed (delegate)")
			stopAudioPlayer()
		}
		print("finished playing delegate")
	}
}
