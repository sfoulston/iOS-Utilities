//
//  SelfSizingContainerView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

open class SelfSizingContainerView: UIView {
	
	open override func didAddSubview(_ subview: UIView) {
		super.didAddSubview(subview)
		subview.translatesAutoresizingMaskIntoConstraints = false
		subview.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		subview.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
		subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
