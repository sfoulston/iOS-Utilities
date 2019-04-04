//
//  UITableView+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public extension UITableView {
	
	/// Uses layout constraints to automatically size the table's header view. Call this method within
	/// `viewDidLayoutSubviews()` to ensure the header view is resized at appropriate times.
	func layoutTableHeaderView() {
		guard let headerView = tableHeaderView else { return }
		headerView.translatesAutoresizingMaskIntoConstraints = false
		
		let widthConstraint = headerView.widthAnchor.constraint(equalToConstant: bounds.width)
		
		widthConstraint.isActive = true
		let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		widthConstraint.isActive = false
		
		headerView.frame = CGRect(origin: .zero, size: headerSize)
		headerView.translatesAutoresizingMaskIntoConstraints = true
	}
}
