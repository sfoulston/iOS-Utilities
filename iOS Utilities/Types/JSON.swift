//
//  JSON.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 07/10/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public enum JSON {
	case object([String : JSON])
	case array([JSON])
	case string(String)
	case bool(Bool)
	case number(Float)
	case null
}

extension JSON: Codable {
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		if let object = try? container.decode([String : JSON].self) {
			self = .object(object)
		} else if let array = try? container.decode([JSON].self) {
			self = .array(array)
		} else if let string = try? container.decode(String.self) {
			self = .string(string)
		} else if let bool = try? container.decode(Bool.self) {
			self = .bool(bool)
		} else if let number = try? container.decode(Float.self) {
			self = .number(number)
		} else if container.decodeNil() {
			self = .null
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Invalid JSON value.")
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		switch self {
		case let .object(object):
			try container.encode(object)
		case let .array(array):
			try container.encode(array)
		case let .string(string):
			try container.encode(string)
		case let .bool(bool):
			try container.encode(bool)
		case let .number(number):
			try container.encode(number)
		case .null:
			try container.encodeNil()
		}
	}
}
