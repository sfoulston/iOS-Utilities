//
//  OffScreenViewRegistrar.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public protocol OffScreenViewRegistrar: class {
	
	// MARK: Properties
	
	var offScreenViewsByTypeName: [String:[String:UIView]] { get set }
	
	var registeredViewClassesByTypeName: [String:[String:AnyClass]] { get set }
	
	var registeredViewNibsByTypeName: [String:[String:UINib]] { get set }
	
	// MARK: Registering Views
	
	func registerClass<View: UIView>(_ viewClass: View.Type?, forOffScreenViewTypeName typeName: String, reuseIdentifier identifier: String)
	
	func registerNib(_ nib: UINib?, forOffScreenViewWithTypeName typeName: String, reuseIdentifier identifier: String)
	
	// MARK: Dequeueing Views
	
	func dequeueReusableOffScreenViewWithTypeName<View: UIView>(_ typeName: String, reuseIdentifier identifier: String) -> View
}

public extension OffScreenViewRegistrar {
	
	// MARK: Registering Views
	
	func typeName<View>(for viewType: View.Type) -> String where View: UIView {
		return String(describing: viewType)
	}
	
	func registerClass<View: UIView>(_ viewClass: View.Type?, forOffScreenViewTypeName typeName: String, reuseIdentifier identifier: String) {
		var registeredViewClasses: [String:AnyClass]! = registeredViewClassesByTypeName[typeName]
		if registeredViewClasses == nil {
			registeredViewClasses = [:]
		}
		
		registeredViewClasses[identifier] = viewClass
		
		registeredViewClassesByTypeName[typeName] = registeredViewClasses
	}
	
	func registerNib(_ nib: UINib?, forOffScreenViewWithTypeName typeName: String, reuseIdentifier identifier: String) {
		var registeredViewNibs: [String:UINib]! = registeredViewNibsByTypeName[typeName]
		if registeredViewNibs == nil {
			registeredViewNibs = [:]
		}
		
		registeredViewNibs[identifier] = nib
		
		registeredViewNibsByTypeName[typeName] = registeredViewNibs
	}
	
	// MARK: Dequeueing Views
	
	func dequeueReusableOffScreenViewWithTypeName<View: UIView>(_ typeName: String, reuseIdentifier identifier: String) -> View {
		var offScreenViews: [String:UIView]! = offScreenViewsByTypeName[typeName]
		if offScreenViews == nil {
			offScreenViews = [:]
		}
		
		var view: View! = offScreenViews[identifier] as? View
		if view == nil {
			if let cellNib = registeredViewNibsByTypeName[typeName]?[identifier] {
				view = cellNib.instantiate(withOwner: nil, options: nil).first as? View
			} else if let ViewClass = registeredViewClassesByTypeName[typeName]?[identifier] as? View.Type {
				view = ViewClass.init()
			} else {
				fatalError("\(identifier) is not registered in \(self)")
			}
			
			offScreenViews[identifier] = view
		}
		
		offScreenViewsByTypeName[typeName] = offScreenViews
		
		return view
	}
}
