//
//  OffScreenViewCollectionView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public class OffScreenViewCollectionView: UICollectionView, OffScreenViewRegistrar {
	
	// MARK: OffScreenViewRegistrar
	
	public var offScreenViewsByTypeName = [String:[String:UIView]]()
	
	public var registeredViewClassesByTypeName = [String:[String:AnyClass]]()
	
	public var registeredViewNibsByTypeName = [String:[String:UINib]]()
	
	// MARK: Creating Collection View Cells
	
	override public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
		super.register(cellClass, forCellWithReuseIdentifier: identifier)
		registerClass(
			cellClass as? UICollectionViewCell.Type,
			forOffScreenViewTypeName: cellTypeName,
			reuseIdentifier: identifier)
	}
	
	override public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
		super.register(nib, forCellWithReuseIdentifier: identifier)
		registerNib(
			nib,
			forOffScreenViewWithTypeName: cellTypeName,
			reuseIdentifier: identifier)
	}
	
	override public func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
		super.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
		registerClass(
			viewClass as? UICollectionReusableView.Type,
			forOffScreenViewTypeName: typeNameForSupplementaryViewOfKind(kind),
			reuseIdentifier: identifier)
	}
	
	override public func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
		super.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
		registerNib(
			nib,
			forOffScreenViewWithTypeName: typeNameForSupplementaryViewOfKind(kind),
			reuseIdentifier: identifier
		)
	}
	
	public func dequeueReusableOffScreenCell(withReuseIdentifier identifier: String) -> UICollectionViewCell {
		return dequeueReusableOffScreenViewWithTypeName(
			cellTypeName,
			reuseIdentifier: identifier
		)
	}
	
	public func dequeueReusableOffScreenSupplementaryView(ofKind kind: String, withReuseIdentifier identifier: String) -> UICollectionReusableView {
		return dequeueReusableOffScreenViewWithTypeName(
			typeNameForSupplementaryViewOfKind(kind),
			reuseIdentifier: identifier
		)
	}
	
	// MARK: Type Names
	
	private var cellTypeName: String {
		return typeName(for: UICollectionViewCell.self)
	}
	
	private func typeNameForSupplementaryViewOfKind(_ kind: String) -> String {
		return kind + "." + typeName(for: UICollectionReusableView.self)
	}
}
