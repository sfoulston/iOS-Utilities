//
//  UIButton+VerticalComponents.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public extension UIButton {
	
	func centerComponentsVertically(withPadding padding: CGFloat) {
		let imageSize = imageView?.frame.size ?? .zero
		let titleSize = titleLabel?.frame.size ?? .zero
		
		imageEdgeInsets = UIEdgeInsets(
			top: -(titleSize.height + padding),
			left: 0,
			bottom: 0,
			right: -titleSize.width
		)
		
		titleEdgeInsets = UIEdgeInsets(
			top: 0,
			left: -imageSize.width,
			bottom: -(imageSize.height + padding),
			right: 0
		)
		
		contentEdgeInsets = UIEdgeInsets(
			top: (titleSize.height + padding) / 2,
			left: -imageSize.width / 2,
			bottom: (titleSize.height + padding) / 2,
			right: -imageSize.width / 2
		)
	}
	
	func centerComponentsVertically() {
		centerComponentsVertically(withPadding: 4)
	}
}
