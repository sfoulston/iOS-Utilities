//
//  UIImage+Orientation+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 07/11/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension UIImage.Orientation {
	
	init(exifOrientation: Int) {
		switch (exifOrientation) {
		case 1:	// kCGImagePropertyOrientationUp
			self = .up
		case 2: // kCGImagePropertyOrientationUpMirrored
			self = .upMirrored
		case 3: // kCGImagePropertyOrientationDown
			self = .down
		case 4: // kCGImagePropertyOrientationDownMirrored
			self = .downMirrored
		case 5: // kCGImagePropertyOrientationLeftMirrored
			self = .leftMirrored
		case 6: // kCGImagePropertyOrientationRight
			self = .right
		case 7: // kCGImagePropertyOrientationRightMirrored
			self = .rightMirrored
		case 8: // kCGImagePropertyOrientationLeft
			self = .left
		default:
			self = .up
		}
	}
}
