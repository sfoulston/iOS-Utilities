//
//  StoryboardIdentifiable.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public protocol StoryboardIdentifiable {
	
	static var storyboardIdentifier: String { get }
}

public extension StoryboardIdentifiable where Self: UIViewController {
	
	static var storyboardIdentifier: String {
		var identifier = String(describing: self)
		
		let viewControllerSuffix = "ViewController"
		if identifier.hasSuffix(viewControllerSuffix) {
			identifier = identifier.replacingOccurrences(of: viewControllerSuffix, with: "")
		}
		
		let controllerSuffix = "Controller"
		if identifier.hasSuffix(controllerSuffix) {
			identifier = identifier.replacingOccurrences(of: controllerSuffix, with: "")
		}
		
		return identifier
	}
}

extension UIViewController: StoryboardIdentifiable {}

public extension UIStoryboard {
	
	func instantiateViewController<T: UIViewController>() -> T {
		guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
			fatalError("Could not instantiate view controller with identifier \(T.storyboardIdentifier). Did you forget to set the storyboard identifier in your view controller scene?")
		}
		return viewController
	}
}
