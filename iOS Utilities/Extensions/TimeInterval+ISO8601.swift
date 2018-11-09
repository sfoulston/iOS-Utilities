//
//  TimeInterval+ISO8601.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension TimeInterval {
	
	public init?(iso8601Duration durationString: String) {
		// Get the time part from ISO 8601 formatted duration.
		// See: http://en.wikipedia.org/wiki/ISO_8601#Durations
		guard let timeStartIndex = durationString.index(of: "T") else { return nil }
		let timeString = durationString[timeStartIndex...]
		
		let scanner = Scanner(string: String(timeString))
		scanner.scanUpToCharacters(from: .decimalDigits, into: nil)
		
		var totalDuration: TimeInterval = 0
		
		if timeString.contains("H") {
			var hoursString: NSString?
			scanner.scanUpTo("H", into: &hoursString)
			scanner.scanUpToCharacters(from: .decimalDigits, into: nil)
			
			if let hoursString = hoursString as String?, let numberOfHours = Int(hoursString) {
				totalDuration += TimeInterval(numberOfHours * 3600)
			}
		}
		
		if timeString.contains("M") {
			var minutesString: NSString?
			scanner.scanUpTo("M", into: &minutesString)
			scanner.scanUpToCharacters(from: .decimalDigits, into: nil)
			
			if let minutesString = minutesString as String?, let numberOfMinutes = Int(minutesString) {
				totalDuration += TimeInterval(numberOfMinutes * 60)
			}
		}
		
		if timeString.contains("S") {
			var secondsString: NSString?
			scanner.scanUpTo("S", into: &secondsString)
			scanner.scanUpToCharacters(from: .decimalDigits, into: nil)
			
			
			if let secondsString = secondsString as String?, let numberOfSeconds = Int(secondsString) {
				totalDuration += TimeInterval(numberOfSeconds)
			}
		}
		
		self = totalDuration
	}
}
