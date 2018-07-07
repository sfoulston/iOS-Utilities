//
//  UIViewAnimationOptions+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 22/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public extension UIViewAnimationOptions {
	
	/// Creates a `UIViewAnimationOptions` value from the specified
	/// `UIViewAnimationCurve` value.
	public init(curve: UIViewAnimationCurve) {
		switch curve {
		case .linear:
			self = .curveLinear
		case .easeIn:
			self = .curveEaseIn
		case .easeOut:
			self = .curveEaseOut
		case .easeInOut:
			self = .curveEaseInOut
		}
	}
}
