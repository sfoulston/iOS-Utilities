//
//  TimeInterval+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 14/09/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension TimeInterval {
	
	public var inThePast: Date {
		return Date() - self
	}
	
	public var inTheFuture: Date {
		return Date() + self
	}
}
