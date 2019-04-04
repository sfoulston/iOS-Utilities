//
//  SegueHandler.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

/// Types (specifically, `UIViewController` subclasses) conforming to this
/// protocol should specify a `enum SegueIdentifier: String` with a `case` for
/// each segue identifier that can be performed by the handler.
///
/// For example:
///
///     enum SegueIdentifier: String {
///         case showNext = "showNext"
///         case showMoreInfo = "showMoreInfo"
///     }
///
/// In `prepare(for:sender:)`, the `UIViewController` handler can then use the
/// `segueIdentifier(for:)` method to switch on the available segue identifiers:
///
///     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
///         switch segueIdentifier(for: segue) {
///         case .showNext:		// Configure...
///         case .showMoreInfo:	// Configure...
///         }
///     }
///
/// If new segues are added, a runtime exception will be raised since the segue
/// is not valid until it has been added as a `SegueIdentifier` case. Once
/// added, the compiler will warn that the switch is non-exhaustive, pointing to
/// the line of code where the new segue should be configured.
public protocol SegueHandler {
	associatedtype SegueIdentifier: RawRepresentable
}

public extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
	
	/// Initiates the segue with the specified identifier from the current view
	/// controller's storyboard file.
	///
	/// - Parameters:
	///	  - segueIdentifier: The enum case that identifies the triggered segue.
	///						 The enum must have a `String` raw value that
	///						 matches the identifier of the segue to be
	///						 triggered. In Interface Builder, you specify the
	///						 segue’s identifier string in the attributes
	///						 inspector.
	///	  - sender: The object that you want to use to initiate the segue. This
	///				object is made available for informational purposes during
	///				the actual segue.
	func performSegue(_ segueIdentifier: SegueIdentifier, sender: AnyObject?) {
		performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
	}
	
	/// Returns the segue identifier enum value that is associated with the
	/// specified segue's string identifier.
	///
	/// - Parameter segue: The storyboard segue for which the corresponding
	///					   segue identifier enum value is to be found.
	/// - Returns: The `SegueIdentifier` enum value for the specified segue.
	func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
		guard let id = segue.identifier, let segueID = SegueIdentifier(rawValue: id) else {
			fatalError("Invalid segue identifier '\(String(describing: segue.identifier))' for view controller of type '\(type(of: self))'.")
		}
		return segueID
	}
}
