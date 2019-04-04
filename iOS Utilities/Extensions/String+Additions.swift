//
//  String+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension String {
	
	// MARK: Hexadecimal Data
	
	/// Create `Data` from hexadecimal string representation.
	///
	/// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or
	/// non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are
	/// processed.
	///
	/// - Returns: Data represented by this hexadecimal string.
	func hexadecimalData() -> Data? {
		var data = Data(capacity: count / 2)
		
		let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
		regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
			let byteString = (self as NSString).substring(with: match!.range)
			var num = UInt8(byteString, radix: 16)!
			data.append(&num, count: 1)
		}
		
		guard data.count > 0 else {
			return nil
		}
		
		return data
	}
	
	// MARK: Truncation
	
	enum TruncationPosition {
		case head
		case middle
		case tail
	}
	
	func truncated(characterLimit: Int, position: TruncationPosition = .tail, leader: String = "…") -> String {
		guard count > characterLimit else { return self }
		
		switch position {
		case .head:
			return leader + self.suffix(characterLimit)
		case .middle:
			let headCharactersCount = Int(ceil(Float(characterLimit - leader.count) / 2))
			let tailCharactersCount = Int(floor(Float(characterLimit - leader.count) / 2))
			return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
		case .tail:
			return self.prefix(characterLimit) + leader
		}
	}
	
	// MARK: HTML
	
	func deletingHTMLTag(_ tag: String) -> String {
		return self.replacingOccurrences(
			of: "(?i)</?\(tag)\\b[^<]*>",
			with: "",
			options: .regularExpression,
			range: nil)
	}
	
	func deletingHTMLTags(_ tags: [String]) -> String {
		return tags.reduce(self) { $0.deletingHTMLTag($1) }
	}
}
