//
//  CharacterSet+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension CharacterSet {
	
	public var allCharacters: [Character] {
		let allCharacters = (UInt8(0)...16).filter { hasMember(inPlane: $0) }.flatMap { (plane) -> [Character] in
			let unicodeRange = (UInt32(plane) << 16)..<(UInt32(plane + 1) << 16)
			return unicodeRange.compactMap { (unicode) -> Character? in
				if let uniChar = UnicodeScalar(unicode), contains(uniChar) {
					return Character(uniChar)
				} else {
					return nil
				}
			}
		}
		return allCharacters
	}
	
	public func randomString(length: Int) -> String {
		let characters = allCharacters
		let numberOfCharacters = characters.count
		let randomString = (0..<length).reduce(into: "") { (string, _) in
			let randomIndex = Int(arc4random_uniform(UInt32(numberOfCharacters)))
			let randomCharacter = characters[randomIndex]
			string += String(randomCharacter)
		}
		return randomString
	}
}
