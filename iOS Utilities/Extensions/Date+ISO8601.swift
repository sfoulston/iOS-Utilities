//
//  Date+ISO8601.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension Date {
	
	init?(iso8601Date dateString: String) {
		guard let date = Date.iso8601Formatter.date(from: dateString) else { return nil }
		self = date
	}
	
	private static let iso8601Formatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [
			.withFullDate,
			.withTime,
			.withDashSeparatorInDate,
			.withColonSeparatorInTime
		]
		return formatter
	}()
}
