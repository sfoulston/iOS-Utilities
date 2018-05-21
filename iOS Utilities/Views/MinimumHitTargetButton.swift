//
//  MinimumHitTargetButton.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

/// A `UIButton` subclass that increases the hit target size to a minimum size.
/// This is helpful for buttons where the bounds are small, and content insets
/// aren't an appropriate mechanism for increasing the tappable area of the
/// button.
@IBDesignable
open class MinimumHitTargetButton: UIButton {
	
	// MARK: Properties
	
	@IBInspectable
	open var minimumHitTargetDimension: CGFloat = 44
	
	// MARK: Hit Testing
	
	override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let hitBounds = bounds.insetBy(
			dx: -max(minimumHitTargetDimension - bounds.width, 0) / 2,
			dy: -max(minimumHitTargetDimension - bounds.height, 0) / 2
		)
		return hitBounds.contains(point)
	}
}
