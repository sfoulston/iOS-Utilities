//
//  FadingVolumePlayer.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import AVFoundation

class FadingVolumePlayer: AVPlayer {
	
	// MARK: Types
	
	typealias FadeCompletion = (Bool) -> Void
	
	// MARK: Constants
	
	private enum Fade {
		static let interval: TimeInterval = 0.05
		static let volumeCloseEnough: Float = 0.05
	}
	
	// MARK: Properties
	
	var isPlaying: Bool { return (timeControlStatus == .playing) }
	
	var fading: Bool { return fadeTimer?.isValid == true }
	
	private(set) var isFadingIn = false
	
	private(set) var isFadingOut = false
	
	private var playStopOriginalVolume: Float = 0.0
	
	private var fadeCompletion: FadeCompletion?
	
	private var fadeTimer: Timer?
	
	// MARK: Fading
	
	func fade(toVolume: Float, duration: TimeInterval, easingFunction: Easing.Function = .linear, easingCurve: Easing.Curve = .inOut, completion: FadeCompletion? = nil) {
		// Invalidate any current fade.
		if fadeTimer?.isValid == true {
			fadeTimer?.invalidate()
			fadeTimer = nil
			fireCompletionHandler(finished: false)
		}
		
		if duration <= 0 || abs(toVolume - volume) < Fade.volumeCloseEnough {
			// Volume is close enough, just set it immediately.
			volume = toVolume
			completion?(true)
			return
		}
		
		let startVolume = volume
		let startTimestamp = Date.timeIntervalSinceReferenceDate
		let endTimestamp = startTimestamp + duration
		
		fadeCompletion = completion
		
		fadeTimer = Timer.schedule(every: Fade.interval) { [weak self] timer in
			let timestamp = Date.timeIntervalSinceReferenceDate
			if timestamp < endTimestamp {
				self?.volume = Float(Easing.ease(
					Double(timestamp),
					function: easingFunction,
					curve: easingCurve,
					direction: startVolume < toVolume ? .positive : .negative,
					domain: Double(startTimestamp)...Double(endTimestamp),
					range: Double(min(startVolume, toVolume))...Double(max(startVolume, toVolume))
				))
			} else {
				timer.invalidate()
				self?.fadeTimer = nil
				self?.volume = toVolume
				self?.fireCompletionHandler(finished: true)
			}
		}
	}
	
	func play(atRate rate: Float = 1, withFadeDuration duration: TimeInterval, easingFunction: Easing.Function = .linear, easingCurve: Easing.Curve = .inOut, completion: FadeCompletion? = nil) {
		if !fading {
			playStopOriginalVolume = volume
		}
		
		if !isPlaying {
			volume = 0
		}
		
		playImmediately(atRate: rate)
		
		fade(toVolume: playStopOriginalVolume, duration: duration, easingFunction: easingFunction, easingCurve: easingCurve) { [weak self] finished in
			self?.isFadingIn = false
			completion?(finished)
		}
		
		if fading {
			isFadingIn = true
		}
	}
	
	func pause(withFadeDuration duration: TimeInterval, easingFunction: Easing.Function = .linear, easingCurve: Easing.Curve = .inOut, completion: FadeCompletion? = nil) {
		guard isPlaying else {
			rate = 0
			completion?(true)
			return
		}
		
		if !fading {
			playStopOriginalVolume = volume
		}
		let originalVolume = playStopOriginalVolume
		
		fade(toVolume: 0, duration: duration, easingFunction: easingFunction, easingCurve: easingCurve) { [weak self] finished in
			if finished {
				self?.rate = 0
				self?.volume = originalVolume
			}
			self?.isFadingOut = false
			completion?(finished)
		}
		
		if fading {
			isFadingOut = true
		}
	}
	
	override func pause() {
		pause(withFadeDuration: 0)
	}
}

// MARK: Helpers

private extension FadingVolumePlayer {
	
	func fireCompletionHandler(finished: Bool) {
		if let completion = fadeCompletion {
			fadeCompletion = nil
			completion(finished)
		}
	}
}
