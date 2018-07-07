//
//  SenderWrapper.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 22/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

/// A wrapper for allowing any type (including value types) be sent as an
/// `NSObject`, for example when performing segues.
public class SenderWrapper<T> {
	
	// MARK: Properties
	
	public let value: T
	
	// MARK: Lifecycle
	
	public init(_ value: T) {
		self.value = value
	}
}
