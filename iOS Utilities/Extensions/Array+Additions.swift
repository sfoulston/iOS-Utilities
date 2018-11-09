//
//  Array+Additions.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public extension Array {
	
	public func intoChunks(of size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0..<Swift.min($0 + size, count)])
		}
	}
	
	/// Inserts the specified element at a random index.
	///
	/// - Returns: The index the element was inserted at.
	@discardableResult
	public mutating func insertAtRandomIndex(_ newElement: Element) -> Int {
		let randomIndex = Int(arc4random_uniform(UInt32(count+1)))
		insert(newElement, at: randomIndex)
		return randomIndex
	}
	
	/// Randomizes the order of the receiver's elements and returns them in a new array.
	///
	/// - Returns: A new array containing the receiver's elements in a random odrer.
	public func randomized() -> Array {
		var randomArray = [Element]()
		self.forEach { randomArray.insertAtRandomIndex($0) }
		return randomArray
	}
}
