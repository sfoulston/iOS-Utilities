//
//  PassthroughView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

open class PassthroughView: UIView {
	
	open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		if hitView == self { return nil }
		return hitView
	}
}
