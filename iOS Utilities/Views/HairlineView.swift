//
//  HairlineView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

class HairlineView: UIView {
	
	// MARK: Types
	
	enum Orientation: Int {
		case horizontal
		case vertical
	}
	
	// MARK: Properties
	
	var orientation: Orientation = .horizontal {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
	
	// MARK: Layout
	
	override var intrinsicContentSize : CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: 1 / UIScreen.main.scale)
	}
}
