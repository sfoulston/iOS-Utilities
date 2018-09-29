//
//  Utilities.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

// MARK: - Control Flow Helpers

extension Int {
	
	public func iterations(_ code: () -> Void) {
		for _ in 0..<self { code() }
	}
	
	public func iterations(_ code: (Int) -> Void) {
		for i in 0..<self { code(i) }
	}
}

// MARK: - DispatchQueue

public func onMainThread(execute code: @escaping () -> Void) {
	Thread.isMainThread ? code() : DispatchQueue.main.async(execute: code)
}

extension DispatchQueue {
	
	public func async(after delay: TimeInterval, execute work: @escaping () -> Void) {
		asyncAfter(deadline: .now() + delay, execute: work)
	}
}

// MARK: - Assertions

public func assertMainThread() {
	assert(Thread.isMainThread, "This code must be executed on the main thread")
}

public func mustOverride(file: String = #file, line: UInt = #line, function: String = #function) -> Never  {
	fatalError("\((file as NSString).lastPathComponent)(\(line)) \(function) must be overridden in a subclass/extension.")
}

// MARK: - RawRepresentable

public protocol CountedRawRepresentable: RawRepresentable {
	
	static var count: Int { get }
}

public extension CountedRawRepresentable where Self.RawValue == Int {
	
	static var count: Int {
		var max = 0
		while Self(rawValue: max) != nil {
			max += 1
		}
		return max
	}
}

public protocol ShorthandRawRepresentable: RawRepresentable {
	
	init(_ section: Self.RawValue)
}

public extension ShorthandRawRepresentable {
	
	init(_ value: Self.RawValue) {
		self.init(rawValue: value)!
	}
}

// MARK: - Time

public extension Int {
	var millisecond:  TimeInterval { return TimeInterval(self / 1_000) }
	var milliseconds: TimeInterval { return TimeInterval(self / 1_000) }
	var second:		  TimeInterval { return TimeInterval(self) }
	var seconds:	  TimeInterval { return TimeInterval(self) }
	var minute:		  TimeInterval { return TimeInterval(self * 60) }
	var minutes:	  TimeInterval { return TimeInterval(self * 60) }
	var hour:		  TimeInterval { return TimeInterval(self * 3_600) }
	var hours:		  TimeInterval { return TimeInterval(self * 3_600) }
	var day:		  TimeInterval { return TimeInterval(self * 86_400) }
	var days:		  TimeInterval { return TimeInterval(self * 86_400) }
	var week:		  TimeInterval { return TimeInterval(self * 604_800) }
	var weeks:		  TimeInterval { return TimeInterval(self * 604_800) }
}

public extension Float {
	var millisecond:  TimeInterval { return TimeInterval(self / 1_000) }
	var milliseconds: TimeInterval { return TimeInterval(self / 1_000) }
	var second:		  TimeInterval { return TimeInterval(self) }
	var seconds:	  TimeInterval { return TimeInterval(self) }
	var minute:		  TimeInterval { return TimeInterval(self * 60) }
	var minutes:	  TimeInterval { return TimeInterval(self * 60) }
	var hour:		  TimeInterval { return TimeInterval(self * 3_600) }
	var hours:		  TimeInterval { return TimeInterval(self * 3_600) }
	var day:		  TimeInterval { return TimeInterval(self * 86_400) }
	var days:		  TimeInterval { return TimeInterval(self * 86_400) }
	var week:		  TimeInterval { return TimeInterval(self * 604_800) }
	var weeks:		  TimeInterval { return TimeInterval(self * 604_800) }
}

public extension Double {
	var millisecond:  TimeInterval { return self / 1_000 }
	var milliseconds: TimeInterval { return self / 1_000 }
	var second:		  TimeInterval { return self }
	var seconds:	  TimeInterval { return self }
	var minute:		  TimeInterval { return self * 60 }
	var minutes:	  TimeInterval { return self * 60 }
	var hour:		  TimeInterval { return self * 3_600 }
	var hours:		  TimeInterval { return self * 3_600 }
	var day:		  TimeInterval { return TimeInterval(self * 86_400) }
	var days:		  TimeInterval { return TimeInterval(self * 86_400) }
	var week:		  TimeInterval { return TimeInterval(self * 604_800) }
	var weeks:		  TimeInterval { return TimeInterval(self * 604_800) }
}

public extension Int {
	var millisecondDuration:  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self / 1_000), unit: .seconds) }
	var millisecondsDuration: Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self / 1_000), unit: .seconds) }
	var secondDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .seconds) }
	var secondsDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .seconds) }
	var minuteDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .minutes) }
	var minutesDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .minutes) }
	var hourDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .hours) }
	var hoursDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .hours) }
	var dayDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 24), unit: .hours) }
	var daysDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 24), unit: .hours) }
	var weekDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 168), unit: .hours) }
	var weeksDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 168), unit: .hours) }
}

public extension Float {
	var millisecondDuration:  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self / 1_000), unit: .seconds) }
	var millisecondsDuration: Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self / 1_000), unit: .seconds) }
	var secondDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .seconds) }
	var secondsDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .seconds) }
	var minuteDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .minutes) }
	var minutesDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .minutes) }
	var hourDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .hours) }
	var hoursDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self), unit: .hours) }
	var dayDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 24), unit: .hours) }
	var daysDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 24), unit: .hours) }
	var weekDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 168), unit: .hours) }
	var weeksDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: Double(self * 168), unit: .hours) }
}

public extension Double {
	var millisecondDuration:  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self / 1_000, unit: .seconds) }
	var millisecondsDuration: Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self / 1_000, unit: .seconds) }
	var secondDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .seconds) }
	var secondsDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .seconds) }
	var minuteDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .minutes) }
	var minutesDuration:	  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .minutes) }
	var hourDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .hours) }
	var hoursDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self, unit: .hours) }
	var dayDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self * 24, unit: .hours) }
	var daysDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self * 24, unit: .hours) }
	var weekDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self * 168, unit: .hours) }
	var weeksDuration:		  Measurement<UnitDuration> { return Measurement<UnitDuration>(value: self * 168, unit: .hours) }
}
