//
//  Timer+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension Timer {
	
	class func schedule(
		after intervalFromNow: TimeInterval,
		for runLoopMode: RunLoopMode = .commonModes,
		handler: @escaping (Timer) -> Void
		) -> Timer {
		let fireDate = CFAbsoluteTimeGetCurrent() + intervalFromNow
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, { timer in handler(timer!) })!
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode(rawValue: runLoopMode.rawValue as CFString))
		return timer
	}
	
	class func schedule(
		every interval: TimeInterval,
		for runLoopMode: RunLoopMode = .commonModes,
		handler: @escaping (Timer) -> Void
		) -> Timer {
		let fireDate = CFAbsoluteTimeGetCurrent() + interval
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, { timer in handler(timer!) })!
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode(rawValue: runLoopMode.rawValue as CFString))
		return timer
	}
}
