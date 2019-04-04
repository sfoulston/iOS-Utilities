//
//  NSMutableAttributedString+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension NSMutableAttributedString {
	
	func setFontFace(font: UIFont, color: UIColor? = nil) {
		beginEditing()
		enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, stop in
			if let f = value as? UIFont, let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
				let newFont = UIFont(descriptor: newFontDescriptor, size: f.pointSize)
				removeAttribute(.font, range: range)
				addAttribute(.font, value: newFont, range: range)
				if let color = color {
					removeAttribute(.foregroundColor, range: range)
					addAttribute(.foregroundColor, value: color, range: range)
				}
			}
		}
		endEditing()
	}
}
