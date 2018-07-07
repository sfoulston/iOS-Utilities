//
//  KeyboardObserving.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 22/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

public protocol KeyboardObserving: class {
	
	var keyboardObserver: NSObjectProtocol? { get set }
	
	var currentKeyboardBottomInset: CGFloat { get set }
	
	func startListeningForKeyboardNotifications()
	
	func stopListeningForKeyboardNotifications()
	
	func updateSafeArea(forKeyboardFrame keyboardFrame: CGRect, animationDuration: TimeInterval, animationCurve: UIViewAnimationCurve)
}

public extension KeyboardObserving {
	
	func startListeningForKeyboardNotifications() {
		stopListeningForKeyboardNotifications()
		keyboardObserver = NotificationCenter.default.addObserver(
			forName: .UIKeyboardWillChangeFrame,
			object: nil,
			queue: .main,
			using: { [weak self] notification in self?.keyboardWillChangeFrame(notification) }
		)
	}
	
	func stopListeningForKeyboardNotifications() {
		if let observer = keyboardObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
}

// MARK: Helpers

private extension KeyboardObserving {
	
	func keyboardWillChangeFrame(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		
		// Don't do anything if the keyboard is not local to this app.
		guard (userInfo[UIKeyboardIsLocalUserInfoKey] as? Bool) != false else { return }
		
		// Only continue if we can get the keyboard frame.
		guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		
		// Get the animation properties.
		let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
		let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? UIViewAnimationCurve.easeOut.rawValue
		let animationCurve = UIViewAnimationCurve(rawValue: animationCurveRaw) ?? .easeOut
		
		updateSafeArea(forKeyboardFrame: keyboardFrame, animationDuration: animationDuration, animationCurve: animationCurve)
	}
}

// MARK: UIViewController+KeyboardObserving

public extension KeyboardObserving where Self: UIViewController {
	
	public func updateSafeArea(forKeyboardFrame keyboardFrame: CGRect, animationDuration: TimeInterval, animationCurve: UIViewAnimationCurve) {
		// Calculate the intersection of the keyboard from with the existing
		// safe area.
		let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
		var safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
		safeAreaFrame.size.height += additionalSafeAreaInsets.bottom
		let intersection = safeAreaFrame.intersection(keyboardFrameInView)
		
		let options = UIViewAnimationOptions(curve: animationCurve).union([.beginFromCurrentState, .allowUserInteraction])
		
		// Animate the new safe area.
		UIView.animate(
			withDuration: animationDuration,
			delay: 0,
			options: options,
			animations: {
				self.currentKeyboardBottomInset = intersection.height
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			},
			completion: nil
		)
	}
}
