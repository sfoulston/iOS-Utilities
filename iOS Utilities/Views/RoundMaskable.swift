//
//  RoundMaskable.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 27/09/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public protocol RoundMaskable: class {
	var rounding: Rounding { get set }
	var maskLayer: CAShapeLayer! { get set }
}

public enum Rounding {
	case radius(CGFloat)
	case percent(CGFloat)
}

public extension RoundMaskable where Self: UIView {
	
	fileprivate func updateMask() {
		let radius = cornerRadius(for: bounds.size)
		
		if let color = backgroundColor, color.cgColor.alpha == 1 {
			if maskLayer == nil {
				maskLayer = CAShapeLayer()
				maskLayer.shouldRasterize = true
				maskLayer.rasterizationScale = UIScreen.main.scale
				layer.addSublayer(maskLayer)
			}
			layer.cornerRadius = 0
			maskLayer.shouldRasterize = false
			layer.shouldRasterize = false
			
			maskLayer.fillColor = color.cgColor
			
			let maskFrame = bounds.insetBy(dx: -1, dy: -1)
			maskLayer.frame = maskFrame
			
			let squarePath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: maskFrame.size))
			let roundedPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).reversing()
			roundedPath.apply(CGAffineTransform(translationX: 1, y: 1))
			squarePath.append(roundedPath)
			squarePath.usesEvenOddFillRule = true
			maskLayer.path = squarePath.cgPath
		} else {
			maskLayer?.removeFromSuperlayer()
			layer.cornerRadius = radius
			layer.masksToBounds = true
			layer.shouldRasterize = true
			layer.rasterizationScale = UIScreen.main.scale
		}
	}
	
	private func cornerRadius(for size: CGSize) -> CGFloat {
		switch rounding {
		case .radius(let cornerRadius):
			return cornerRadius
		case .percent(let percent):
			return percent * smallestDimension(for: size) / 2
		}
	}
	
	private func smallestDimension(for size: CGSize) -> CGFloat {
		return min(size.width, size.height)
	}
}

// MARK: -

@IBDesignable
open class RoundMaskingView: UIView, RoundMaskable {
	
	public var rounding: Rounding = .percent(1) {
		didSet {
			updateMask()
		}
	}
	
	@IBInspectable
	public var roundnessPercent: CGFloat = 1 {
		didSet {
			rounding = .percent(roundnessPercent)
		}
	}
	
	@IBInspectable
	public var cornerRadius: CGFloat = -1 {
		didSet {
			if cornerRadius >= 0 {
				rounding = .radius(cornerRadius)
			}
		}
	}
	
	public var maskLayer: CAShapeLayer!
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		updateMask()
	}
	
	override open var backgroundColor: UIColor? {
		didSet {
			updateMask()
		}
	}
}

// MARK: -

@IBDesignable
open class RoundMaskingImageView: UIImageView, RoundMaskable {
	
	public var rounding: Rounding = .percent(1) {
		didSet {
			updateMask()
		}
	}
	
	@IBInspectable
	public var roundnessPercent: CGFloat = 1 {
		didSet {
			rounding = .percent(roundnessPercent)
		}
	}
	
	@IBInspectable
	public var cornerRadius: CGFloat = -1 {
		didSet {
			if cornerRadius >= 0 {
				rounding = .radius(cornerRadius)
			}
		}
	}
	
	public var maskLayer: CAShapeLayer!
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		updateMask()
	}
	
	override open var backgroundColor: UIColor? {
		didSet {
			updateMask()
		}
	}
}

// MARK: -

@IBDesignable
open class RoundMaskingButton: UIButton, RoundMaskable {
	
	public var rounding: Rounding = .percent(1) {
		didSet {
			updateMask()
		}
	}
	
	@IBInspectable
	public var roundnessPercent: CGFloat = 1 {
		didSet {
			rounding = .percent(roundnessPercent)
		}
	}
	
	@IBInspectable
	public var cornerRadius: CGFloat = -1 {
		didSet {
			if cornerRadius >= 0 {
				rounding = .radius(cornerRadius)
			}
		}
	}
	
	public var maskLayer: CAShapeLayer!
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		updateMask()
	}
	
	override open var backgroundColor: UIColor? {
		didSet {
			updateMask()
		}
	}
}
