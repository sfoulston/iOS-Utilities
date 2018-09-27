//
//  FadingImageView.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import UIKit

@IBDesignable
public class FadingImageView: UIImageView {
	
	// MARK: Constants
	
	private enum Constant {
		static let defaultFadeDuration = 0.3.seconds
	}
	
	// MARK: Lifecycle
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		layer.minificationFilter = CALayerContentsFilter.trilinear
	}
	
	// MARK: Changing the Image
	
	public func setImage(_ newImage: UIImage?, animated: Bool = false, duration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
		guard image != newImage, let superview = superview else {
			return
		}
		
		if animated {
			let transitionImageView = FadingImageView(frame: frame)
			transitionImageView.image = image
			transitionImageView.backgroundColor = backgroundColor
			transitionImageView.contentMode = contentMode
			transitionImageView.clipsToBounds = clipsToBounds
			
			superview.insertSubview(transitionImageView, aboveSubview: self)
			
			UIView.animate(
				withDuration: duration ?? Constant.defaultFadeDuration,
				delay: 0,
				options: .allowUserInteraction,
				animations: {
					transitionImageView.alpha = 0
				},
				completion: { finished in
					transitionImageView.removeFromSuperview()
					completion?(finished)
				})
		}
		
		image = newImage
	}
}

