//
//  UIImage+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public extension UIImage {
	
	static func pixel(color: UIColor = .black) -> UIImage {
		return UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: 1, height: 1)).image { context in
			color.setFill()
			context.fill(context.format.bounds)
		}
	}
}
