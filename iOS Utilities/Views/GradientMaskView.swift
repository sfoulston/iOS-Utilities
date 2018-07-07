//
//  GradientMaskView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 05/07/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientMaskView: UIView {
	
	// MARK: Types
	
	public enum Direction: Int {
		case topToBottom, bottomToTop, leftToRight, rightToLeft
	}
	
	// MARK: Properties
	
	@IBInspectable
	open var directionRaw: Int {
		get { return direction.rawValue }
		set { direction = Direction(rawValue: newValue) ?? .topToBottom }
	}
	
	open var direction: Direction = .topToBottom {
		didSet { updateGradientMask() }
	}
	
	open var gradientLength: CGFloat? {
		didSet {
			updateGradientMask()
		}
	}
	
	private lazy var gradientMask: CAGradientLayer = {
		let mask = CAGradientLayer()
		mask.colors = [
			UIColor.black.cgColor,
			UIColor.black.withAlphaComponent(0).cgColor
		]
		return mask
	}()
	
	// MARK: Lifecycle
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		layer.mask = gradientMask
	}
	
	// MARK: Layout
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		updateGradientMask()
	}
}

// MARK: Helpers

private extension GradientMaskView {
	
	// MARK: Updating the Gradient
	
	func updateGradientMask() {
		gradientMask.frame = bounds
		
		var startX: CGFloat = 0, startY: CGFloat = 0, endX: CGFloat = 0, endY: CGFloat = 0
		switch direction {
		case .topToBottom:	endY	= 1
		case .bottomToTop:	startY	= 1
		case .leftToRight:	endX	= 1
		case .rightToLeft:	startX	= 1
		}
		gradientMask.startPoint = CGPoint(x: startX, y: startY)
		gradientMask.endPoint = CGPoint(x: endX, y: endY)
		
		var startLocation: CGFloat = 0
		if let length = gradientLength {
			switch direction {
			case .topToBottom, .bottomToTop:
				startLocation = 1 - min(max(length/bounds.height, 0), 1)
			case .leftToRight, .rightToLeft:
				startLocation = 1 - min(max(length/bounds.width, 0), 1)
			}
		}
		let locations = [startLocation, 1]
		
		gradientMask.locations = locations as [NSNumber]
	}
}
