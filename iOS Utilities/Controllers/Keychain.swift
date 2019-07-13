//
//  Keychain.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation
import Security

open class Keychain {
	
	// MARK: Types
	
	public typealias Data = NSCoding
	
	public enum SecurityClass {
		case genericPassword
		case internetPassword
		case certificate
		case key
		case identity
	}
	
	public enum AccessLevel {
		case whenUnlocked
		case afterFirstUnlock
		case always
		case whenPasscodeSetThisDeviceOnly
		case whenUnlockedThisDeviceOnly
		case afterFirstUnlockThisDeviceOnly
		case alwaysThisDeviceOnly
	}
	
	// MARK: Performing Requests
	
	open class func perform(_ request: KeychainRequest) -> (data: Data?, error: NSError?) {
		let parsedRequest = parse(request)
		
		var result: AnyObject?
		let status: OSStatus
		
		switch request.type {
		case .create: status = withUnsafeMutablePointer(to: &result) { SecItemAdd(parsedRequest as CFDictionary, UnsafeMutablePointer($0)) }
		case .read:	  status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(parsedRequest as CFDictionary, UnsafeMutablePointer($0)) }
		case .update: status = performUpdate(parsedRequest)
		case .delete: status = SecItemDelete(parsedRequest as CFDictionary)
		}
		
		let error = self.error(for: status)
		var data: Data?
		if request.type == .read && status == errSecSuccess, let encodedData = result as? Foundation.Data {
			data = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? NSCoding
		}
		return (data: data, error: error)
	}
}

// MARK: Convenience Methods

public extension Keychain {
	
	// MARK: Working with Arbitrary Data
	
	@discardableResult
	class func saveData(_ data: Data, forIdentifier identifier: String, service: String? = nil) -> NSError? {
		let saveRequest = KeychainRequest(userAccount: identifier, type: .create, data: data, service: service)
		return Keychain.perform(saveRequest).error
	}
	
	class func loadData(forIdentifier identifier: String, service: String? = nil) -> (data: Data?, error: NSError?) {
		let readRequest = KeychainRequest(userAccount: identifier, type: .read, service: service)
		return Keychain.perform(readRequest)
	}
	
	@discardableResult
	class func updateData(_ data: Data, forIdentifier identifier: String, service: String? = nil) -> NSError? {
		let updateRequest = KeychainRequest(userAccount: identifier, type: .update, data: data, service: service)
		return Keychain.perform(updateRequest).error
	}
	
	@discardableResult
	class func deleteData(forIdentifier identifier: String, service: String? = nil) -> NSError? {
		let deleteRequest = KeychainRequest(userAccount: identifier, type: .delete, service: service)
		return Keychain.perform(deleteRequest).error
	}
	
	// MARK: Working with Passwords
	
	@discardableResult
	class func savePassword(_ password: String, forUserAccount userAccount: String, service: String? = nil) -> NSError? {
		let saveRequest = KeychainRequest(userAccount: userAccount, type: .create, data: password as Keychain.Data?, service: service)
		return Keychain.perform(saveRequest).error
	}
	
	class func loadPassword(forUserAccount userAccount: String, service: String? = nil) -> (password: String?, error: NSError?) {
		let readRequest = KeychainRequest(userAccount: userAccount, type: .read, service: service)
		let (data, error) = Keychain.perform(readRequest)
		return (password: data as? String, error)
	}
	
	@discardableResult
	class func updatePassword(_ password: String, forUserAccount userAccount: String, service: String? = nil) -> NSError? {
		let updateRequest = KeychainRequest(userAccount: userAccount, type: .update, data: password as Keychain.Data?, service: service)
		return Keychain.perform(updateRequest).error
	}
	
	@discardableResult
	class func deletePassword(forUserAccount userAccount: String, service: String? = nil) -> NSError? {
		let deleteRequest = KeychainRequest(userAccount: userAccount, type: .delete, service: service)
		return Keychain.perform(deleteRequest).error
	}
	
	// MARK: Empty the Keychain
	
	@discardableResult
	class func empty() -> NSError? {
		// For each of the sec class types, delete all of the saved items of that type
		let classes = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
		let errors: [NSError?] = classes.map {
			let request: ParsedRequest = [String(kSecClass): $0]
			let status = SecItemDelete(request as CFDictionary)
			return self.error(for: status)
		}
		
		// Remove those that were successful, or failed with an acceptable error code
		// If the error indicates that there was no item with that sec class, that's fine
		let filtered = errors.filter { ($0?.code == Int(errSecItemNotFound)) != true }
		
		// If the filtered array is empty, then everything went fine
		if !filtered.isEmpty {
			return nil
		}
		
		// At least one of the delete operations failed
		let code = Error.Code.unableToClear
		
		return NSError(
			domain: Error.Domain,
			code: code.rawValue,
			userInfo: ["message": Error.message(for: code)]
		)
	}
}

// MARK: Helpers

private extension Keychain {
	
	// MARK: Updating
	
	class func performUpdate(_ parsedRequest: ParsedRequest) -> OSStatus {
		let query = parsedRequest
		var update = parsedRequest
		update[String(kSecClass)] = nil
		return SecItemUpdate(query as CFDictionary, update as CFDictionary)
	}
	
	// MARK: Parsing Requests
	
	typealias ParsedRequest = [AnyHashable: Any]
	
	class func parse(_ request: KeychainRequest) -> ParsedRequest {
		var parsedRequest = ParsedRequest()
		
		var options = [String: AnyObject?]()
		options[String(kSecAttrService)] = request.service as AnyObject??
		options[String(kSecAttrAccount)] = request.userAccount as AnyObject??
		options[String(kSecAttrAccessGroup)] = request.group as AnyObject??
		options[String(kSecAttrSynchronizable)] = request.synchronizable as AnyObject??
		options[String(kSecClass)] = string(for: request.securityClass)
		if let accessLevel = request.accessLevel {
			options[String(kSecAttrAccessible)] = string(for: accessLevel)
		}
		
		for (key, option) in options {
			if let opt: AnyObject = option {
				parsedRequest[key] = opt
			}
		}
		
		switch request.type {
		case .create: parse(createRequest: request, in: &parsedRequest)
		case .read:	  parse(readRequest: request, in: &parsedRequest)
		case .update: parse(updateRequest: request, in: &parsedRequest)
		case .delete: parse(deleteRequest: request, in: &parsedRequest)
		}
		
		return parsedRequest
	}
	
	class func parse(createRequest request: KeychainRequest, in parsedRequest: inout ParsedRequest) {
		if let data: Data = request.data {
			let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
			parsedRequest[String(kSecValueData)] = encodedData
		}
	}
	
	class func parse(readRequest request: KeychainRequest, in parsedRequest: inout ParsedRequest) {
		parsedRequest[String(kSecReturnData)] = kCFBooleanTrue
		switch request.matchLimit {
		case .one:	parsedRequest[String(kSecMatchLimit)] = kSecMatchLimitOne
		case .many:	parsedRequest[String(kSecMatchLimit)] = kSecMatchLimitAll
		}
	}
	
	class func parse(updateRequest request: KeychainRequest, in parsedRequest: inout ParsedRequest) {
		if let data: Data = request.data {
			let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
			parsedRequest[String(kSecValueData)] = encodedData
		}
	}
	
	class func parse(deleteRequest request: KeychainRequest, in parsedRequest: inout ParsedRequest) {
	}
	
	// MARK: Error Handling
	
	struct Error {
		static let Domain = "com.sfoulston.Keychain.error"
		
		enum Code: Int {
			case unableToClear = 1
		}
		
		struct Message {
			// Security framework
			static let allocate = "Failed to allocate memory."
			static let authFailed = "Authorization/Authentication failed."
			static let decode = "Unable to decode the provided data."
			static let duplicate = "The item already exists."
			static let interactionNotAllowed = "Interaction with the Security Server is not allowed."
			static let noError = "No error."
			static let notAvailable = "No trust results are available."
			static let notFound = "The item cannot be found."
			static let param = "One or more parameters passed to the function were not valid."
			static let unimplemented = "Function or operation not implemented."
			
			// Internal
			static let unableToClear = "Unable to clear the keychain."
		}
		
		static func message(for status: OSStatus) -> String {
			switch status {
			case errSecAllocate:				return Message.allocate
			case errSecAuthFailed:				return Message.authFailed
			case errSecDecode:					return Message.decode
			case errSecDuplicateItem:			return Message.duplicate
			case errSecInteractionNotAllowed:	return Message.interactionNotAllowed
			case errSecItemNotFound:			return Message.notFound
			case errSecNotAvailable:			return Message.notAvailable
			case errSecParam:					return Message.param
			case errSecSuccess:					return Message.noError
			case errSecUnimplemented:			return Message.unimplemented
			default:							return "Undocumented error with code \(Int(status))."
			}
		}
		
		static func message(for errorCode: Code) -> String {
			switch errorCode {
			case .unableToClear: return Message.unableToClear
			}
		}
	}
	
	class func error(for status: OSStatus) -> NSError? {
		var error: NSError?
		let statusCode = Int(status)
		if statusCode != Int(errSecSuccess) {
			error = NSError(
				domain: Error.Domain,
				code: statusCode,
				userInfo: ["message": Error.message(for: status)]
			)
		}
		return error
	}
	
	// MARK: Converting Enums to Security Attributes
	
	class func string(for securityClass: Keychain.SecurityClass) -> CFString {
		switch securityClass {
		case .genericPassword:	return kSecClassGenericPassword
		case .certificate:		return kSecClassCertificate
		case .identity:			return kSecClassIdentity
		case .internetPassword:	return kSecClassInternetPassword
		case .key:				return kSecClassKey
		}
	}
	
	class func string(for accessLevel: Keychain.AccessLevel) -> CFString {
		switch accessLevel {
		case .whenUnlocked:						return kSecAttrAccessibleWhenUnlocked
		case .afterFirstUnlock:					return kSecAttrAccessibleAfterFirstUnlock
		case .always:							return kSecAttrAccessibleAlways
		case .whenPasscodeSetThisDeviceOnly:	return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
		case .whenUnlockedThisDeviceOnly:		return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		case .afterFirstUnlockThisDeviceOnly:	return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		case .alwaysThisDeviceOnly:				return kSecAttrAccessibleAlwaysThisDeviceOnly
		}
	}
}

// MARK: - KeychainRequest

/// A request that can be passed to `Keychain.performRequest(_:)` to execute a
/// read/write on the keychain.
///
/// A keychain item is uniquely identified by a different set of attributes
/// depending on the item's class (the value of `kSecClass`). Attempting to add
/// a new item with the same unique attribute values as an existing item will
/// return a duplicate error. Other attributes (e.g. `kSecAttrGeneric`) can
/// still be used in a query to search for a particular item, however different
/// values will not uniquely differentiate items in the keychain. Each item
/// class is uniquely identified as follows:
///
/// - `kSecClassGenericPassword` is uniquely identified by the combination of:
///		+ `kSecAttrAccount`
///		+ `kSecAttrService`
/// - `kSecClassInternetPassword` is uniquely identified by the combination of:
///		+ `kSecAttrAccount`
///		+ `kSecAttrSecurityDomain`
///		+ `kSecAttrServer`
///		+ `kSecAttrProtocol`
///		+ `kSecAttrAuthenticationType`
///		+ `kSecAttrPort`
///		+ `kSecAttrPath`
/// - `kSecClassCertificate` is uniquely identified by the combination of:
///		+ `kSecAttrCertificateType`
///		+ `kSecAttrIssuer`
///		+ `kSecAttrSerialNumber`
/// - `kSecClassKey` is uniquely identified by the combination of:
///		+ `kSecAttrApplicationLabel`
///		+ `kSecAttrApplicationTag`
///		+ `kSecAttrKeyType`
///		+ `kSecAttrSizeInBits`
///		+ `kSecAttrEffectiveKeySize`
/// - `kSecClassIdentity` is a combination of a private key and a certificate,
/// so it is assumed (not documented) that items of this class are uniquely
/// identified by the combination of unique attributes for `kSecClassKey` &
/// `kSecClassCertificate`.
///
/// In addition to the above attributes, `kSecAttrAccessGroup` further
/// differentiates items for any class, since each keychain belongs to a
/// particular keychain access group.
public struct KeychainRequest {
	
	public enum MatchLimit {
		case one, many
	}
	
	public enum RequestType: Int {
		case create, read, update, delete
	}
	
	// MARK: Required Configuration
	
	/// Defaults to the main bundle identifier.
	public var service: String
	
	/// The user account to associate the request with.
	public var userAccount: String
	
	/// The type of Keychain request to make (default is `Read`).
	public var type: RequestType = .read
	
	// MARK: Optional Configuration
	
	/// Default to password lookup.
	public var securityClass: Keychain.SecurityClass = .genericPassword
	public var group: String?
	public var data: Keychain.Data?
	public var matchLimit: MatchLimit = .one
	public var synchronizable = false
	public var accessLevel: Keychain.AccessLevel?
	
	// MARK: Initializers
	
	public init(userAccount: String, type: RequestType = .read, data: Keychain.Data? = nil, service: String? = nil) {
		self.userAccount = userAccount
		self.type = type
		self.data = data
		if let service = service {
			self.service = service
		} else {
			if let mainBundleID = Bundle.main.bundleIdentifier {
				self.service = mainBundleID
			} else if let classBundleID = Bundle(for: Keychain.self).bundleIdentifier {
				self.service = classBundleID
			} else {
				self.service = ""
			}
		}
	}
}

// MARK: CustomDebugStringConvertible

extension KeychainRequest: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "service: \(service), type: \(type.rawValue), account: \(userAccount)"
	}
}
