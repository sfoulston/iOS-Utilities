//
//  Error+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension Error {
	
	var isNoNetworkConnectionError: Bool {
		switch (self as NSError).code {
		case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
			return true
		default:
			return false
		}
	}
	
	var isCancelledRequestError: Bool {
		return (self as NSError).code == NSURLErrorCancelled
	}
}
