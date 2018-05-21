//
//  OffScreenViewTableView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public class OffScreenViewTableView: UITableView, OffScreenViewRegistrar {
	
	// MARK: OffScreenViewRegistrar
	
	public var offScreenViewsByTypeName = [String:[String:UIView]]()
	
	public var registeredViewClassesByTypeName = [String:[String:AnyClass]]()
	
	public var registeredViewNibsByTypeName = [String:[String:UINib]]()
	
	// MARK: Creating Table View Cells
	
	override public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
		super.register(cellClass, forCellReuseIdentifier: identifier)
		registerClass(
			cellClass as? UITableViewCell.Type,
			forOffScreenViewTypeName: cellTypeName,
			reuseIdentifier: identifier
		)
	}
	
	override public func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
		super.register(nib, forCellReuseIdentifier: identifier)
		registerNib(
			nib,
			forOffScreenViewWithTypeName: cellTypeName,
			reuseIdentifier: identifier
		)
	}
	
	public func dequeueReusableOffScreenCellWithReuseIdentifier(_ identifier: String) -> UITableViewCell {
		return dequeueReusableOffScreenViewWithTypeName(
			cellTypeName,
			reuseIdentifier: identifier
		)
	}
	
	// MARK: Type Names
	
	private var cellTypeName: String {
		return typeName(for: UITableViewCell.self)
	}
}
