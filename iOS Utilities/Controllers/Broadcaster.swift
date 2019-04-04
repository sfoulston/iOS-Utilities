//
//  Broadcaster.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

/// Sends broadcasts to objects that subscribe.
///
/// A broadcaster is created as a public property of a class that needs to send
/// broadcasts about certain events. Each broadcaster is responsible for
/// broadcasting a specific payload, specified when the broadcaster is
/// initialised:
///
///	`public var newDataBroadcaster = Broadcaster<NSData>()
///	public var tupleBroadcaster = Broadcaster<(name: String, index: Int)>()`
///
/// Broadcasts are sent by calling `broadcast()`, and any other object can
/// subscribe to receive broadcasts by calling `subscribe()` on the relevant
/// broadcaster.
///
/// This type is safe to use from multiple threads. Note that no guarantee is
/// made about which thread broadcasts are sent from.
public class Broadcaster<Parameters> {
	
	// MARK: Types
	
	/// Represents a subscription to a specific broadcast.
	///
	/// A subscription is vended when an object subscribes to a `Broadcaster`
	/// object and is used to unsubscribe from that broadcaster.
	private class Subscription: BroadcastSubscription {
		
		// MARK: Properties
		
		weak var subscriber: AnyObject?
		
		private unowned var broadcaster: Broadcaster<Parameters>
		
		let callback: Callback
		
		// MARK: Lifecycle
		
		init(subscriber: AnyObject, broadcaster: Broadcaster<Parameters>, callback: @escaping Callback) {
			self.subscriber = subscriber
			self.broadcaster = broadcaster
			self.callback = callback
		}
		
		// MARK: Removing the Subscription
		
		func remove() {
			broadcaster.remove(self)
		}
	}
	
	public typealias Callback = (Parameters) -> Void
	
	// MARK: Properties
	
	private var initialBroadcastParametersClosure: (() -> Parameters)?
	
	private let queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).Broadcaster-Queue", attributes: .concurrent)
	
	// MARK: Lifecycle
	
	public init(initialBroadcastParametersClosure: (() -> Parameters)? = nil) {
		self.initialBroadcastParametersClosure = initialBroadcastParametersClosure
	}
	
	// MARK: Managing Subscriptions
	
	private var subscriptions = [Subscription]()
	
	/// Adds a subscription to the receiver for the specified subscriber, taking
	/// a closure as a callback.
	///
	/// Only objects (not structs/enums) can subscribe using this method. A weak
	/// reference is kept to the subscriber so it can safely be deallocated
	/// without explicitly unsubscribing from the broadcast.
	///
	///	`notifyingObject.tupleBroadcaster.subscribe(self) { name, index in
	///		println("New item '\(name)' at index \(index)")
	/// }`
	///
	/// **Note:** In order for subscriptions to be automatically removed when
	/// the subscriber is deallocated, the `callback` closure must **not**
	/// capture a strong reference to the subscriber, as it will prevent its
	/// deallocation. Avoid this by using a capture list in the closure
	/// declaration as necessary:
	///
	/// `notifyingObject.newDataBroadcaster.subscribe(self) { [weak self] newData -> Void in
	///		self?.processData(newData)
	///		println("Data processed")
	/// }`
	///
	/// - Parameters:
	///		- subscriber:
	///			The object subscribing to receive broadcasts.
	/// 	- callback:
	///			A callback closure to be called for each broadcast. The
	///			closure's parameters must match those of the receiver.
	/// - Returns:
	///		A Subscription object, used to explicitly unsubscribe from the
	///		receiver.
	@discardableResult
	public func subscribe<T: AnyObject>(_ subscriber: T, callback: @escaping Callback) -> BroadcastSubscription {
		let subscription = Subscription(subscriber: subscriber, broadcaster: self, callback: callback)
		add(subscription)
		return subscription
	}
	
	/// Adds a subscription to the receiver.
	///
	/// Any type can subscribe using this method. Subscribers must be sure to
	///	call `unsubscribe()` before being deallocated.
	///
	/// `notifyingObject.newDataBroadcaster.subscribe { newData in
	///		println("Got new data: \(newData)")
	///	}`
	///
	/// - Parameters:
	///		- callback:
	///			A callback closure to be called for each broadcast. The
	///			closure's parameters must match those of the receiver.
	/// - Returns:
	///		A Subscription object, used to unsubscribe from the receiver.
	@discardableResult
	public func subscribe(_ callback: @escaping Callback) -> BroadcastSubscription {
		return subscribe(self, callback: callback)
	}
	
	private func add(_ subscription: Subscription) {
		queue.async(flags: .barrier) {
			self.subscriptions.append(subscription)
			self.subscriptions = self.subscriptions.filter { $0.subscriber != nil }
		}
		if let parameters = initialBroadcastParametersClosure?() {
			subscription.callback(parameters)
		}
	}
	
	/// Removes a subscription from the receiver.
	///
	/// - Parameters
	///		- subscription:
	///			A Subscription object that was returned when subscribing to the
	///			receiver.
	private func remove(_ subscription: Subscription) {
		queue.async(flags: .barrier) {
			self.subscriptions = self.subscriptions.filter { $0 !== subscription && $0.subscriber != nil }
		}
	}
	
	public func unsubscribe<T: AnyObject>(_ subscriber: T) {
		queue.async(flags: .barrier) {
			self.subscriptions = self.subscriptions.filter { $0.subscriber !== subscriber && $0.subscriber != nil }
		}
	}
	
	// MARK: Broadcasting
	
	/// Sends a broadcast with the specified parameters.
	///
	/// - Parameters
	///		- parameters:
	///			The information to send with the broadcast.
	/// - Returns:
	///		The number of subscribers that received this broadcast.
	@discardableResult
	public func broadcast(_ parameters: Parameters) -> Int {
		queue.async(flags: .barrier) {
			self.subscriptions = self.subscriptions.filter { $0.subscriber != nil }
		}
		
		let subscriptions = queue.sync { self.subscriptions }
		subscriptions.forEach { $0.callback(parameters) }
		
		return subscriptions.count
	}
	
	// MARK: Information About Subscribers
	
	/// The current number of subscriptions to this broadcaster.
	public var numberOfSubscriptions: Int {
		queue.async(flags: .barrier) {
			self.subscriptions = self.subscriptions.filter { $0.subscriber != nil }
		}
		let numberOfSubscriptions = queue.sync { subscriptions.count }
		return numberOfSubscriptions
	}
}

extension Broadcaster: Hashable, CustomStringConvertible {
	
	// MARK: Hashable
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
	
	// MARK: Equatable
	
	static public func ==<Parameters>(left: Broadcaster<Parameters>, right: Broadcaster<Parameters>) -> Bool {
		return left.hashValue == right.hashValue
	}
	
	// MARK: CustomStringConvertible
	
	public var description: String {
		let subs = queue.sync { subscriptions }
		
		let strings = subs.map { sub in
			(sub.subscriber === self) ? "\(String(describing: sub.callback))" : "\(String(describing: sub.subscriber)) \(String(describing: sub.callback))"
		}
		let joined = strings.joined(separator: ", ")
		
		return "\(Mirror(reflecting: self)): (\(joined))"
	}
}

// MARK: - BroadcastSubscription

public protocol BroadcastSubscription {
	
	func remove()
}
