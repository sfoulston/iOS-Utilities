//
//  TransparentNavigationBar.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

class TransparentNavigationBar: UINavigationBar {
	
	// MARK: Lifecycle
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setBackgroundImage(UIImage.pixel(color: .clear), for: .default)
		barTintColor = nil
		shadowImage = UIImage.pixel(color: .clear)
		backgroundColor = .clear
		isTranslucent = true
	}
	
	// MARK: Hit Testing
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		// Pass touches through to the underlying view if no subview claims it.
		let hitView = super.hitTest(point, with: event)
		return (hitView === self) ? nil : hitView
	}
}
