//
//  GradientView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 05/07/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

@IBDesignable
open class GradientView: UIView {
	
	// MARK: Types
	
	public enum Direction: Int {
		case up, down, left, right
	}
	
	// MARK: Properties
	
	@IBInspectable
	open var fromColor: UIColor = UIColor.black.withAlphaComponent(0.2) {
		didSet { updateGradient() }
	}
	
	@IBInspectable
	open var toColor: UIColor = UIColor.clear {
		didSet { updateGradient() }
	}
	
	@IBInspectable
	open var directionRaw: Int {
		get { return direction.rawValue }
		set { direction = Direction(rawValue: newValue) ?? .down }
	}
	
	open var direction: Direction = .down {
		didSet { updateGradient() }
	}
	
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
		backgroundColor = UIColor.clear
		updateGradient()
	}
	
	// MARK: Overriding the Layer Class
	
	override open class var layerClass : AnyClass {
		return CAGradientLayer.self
	}
}

// MARK: Helpers

private extension GradientView {
	
	private var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
	
	func updateGradient() {
		gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
		
		var startX = 0, startY = 0, endX = 0, endY = 0
		
		switch direction {
		case .up:		startY	= 1
		case .down:		endY	= 1
		case .left:		startX	= 1
		case .right:	endX	= 1
		}
		
		gradientLayer.startPoint = CGPoint(x: startX, y: startY)
		gradientLayer.endPoint = CGPoint(x: endX, y: endY)
	}
}
