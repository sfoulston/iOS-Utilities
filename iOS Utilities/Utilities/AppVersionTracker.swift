//
//  AppVersionTracker.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

private struct AppVersionTracker {
	
	// MARK: Constants
	
	private enum Keys {
		static let History					= "VersionTracker.HistoryKey"
		static let VersionHistory			= "VersionTracker.VersionHistoryKey"
		static let BuildHistory				= "VersionTracker.BuildHistoryKey"
		
		static let LaunchCounts				= "VersionTracker.LaunchCountsKey"
		static let VersionLaunchCounts		= "VersionTracker.VersionLaunchCountsKey"
		static let BuildLaunchCounts		= "VersionTracker.BuildLaunchCountsKey"
		
		static let FirstLaunchDates			= "VersionTracker.FirstLaunchDatesKey"
		static let VersionFirstLaunchDates	= "VersionTracker.VersionFirstLaunchDatesKey"
		static let BuildFirstLaunchDates	= "VersionTracker.BuildFirstLaunchDatesKey"
		
		static let LastLaunchDates			= "VersionTracker.LastLaunchDatesKey"
		static let VersionLastLaunchDates	= "VersionTracker.VersionLastLaunchDatesKey"
		static let BuildLastLaunchDates		= "VersionTracker.BuildLastLaunchDatesKey"
	}
	
	// MARK: Properties
	
	fileprivate static var tracker = AppVersionTracker()
	
	private var history: [String: [String]]!
	private var launchCounts: [String: [String: Int]]!
	private var firstLaunchDates: [String: [String: Date]]!
	private var lastLaunchDates: [String: [String: Date]]!
	
	private var totalLaunchCount: Int {
		return launchCounts?[Keys.VersionLaunchCounts]?.map { $1 }.reduce(0, +) ?? 0
	}
	
	private var firstEverLaunchDate: Date {
		guard let earliestVersion = history?[Keys.VersionHistory]?.first else { return Date() }
		return firstLaunchDates?[Keys.VersionFirstLaunchDates]?[earliestVersion] ?? Date()
	}
	
	// MARK: Tracking Launces
	
	/// Call each time the app is launched.
	fileprivate static func track() {
		let defaults = UserDefaults.standard
		
		var history			 = defaults.object(forKey: Keys.History) as? [String: [String]]					?? [Keys.VersionHistory: [], Keys.BuildHistory: []]
		var launchCounts	 = defaults.object(forKey: Keys.LaunchCounts) as? [String: [String: Int]]		?? [Keys.VersionLaunchCounts: [:], Keys.BuildLaunchCounts: [:]]
		var firstLaunchDates = defaults.object(forKey: Keys.FirstLaunchDates) as? [String: [String: Date]]	?? [Keys.VersionFirstLaunchDates: [:], Keys.BuildFirstLaunchDates: [:]]
		var lastLaunchDates	 = defaults.object(forKey: Keys.LastLaunchDates) as? [String: [String: Date]]	?? [Keys.VersionLastLaunchDates: [:], Keys.BuildLastLaunchDates: [:]]
		
		let dateNow = Date()
		
		// Update the version info
		let thisVersion = currentVersion
		var versionHist				= history[Keys.VersionHistory]!
		var versionLaunchCts		= launchCounts[Keys.VersionLaunchCounts]!
		var versionFirstLaunchDts	= firstLaunchDates[Keys.VersionFirstLaunchDates]!
		var versionLastLaunchDts	= lastLaunchDates[Keys.VersionLastLaunchDates]!
		if !versionHist.contains(thisVersion) {
			versionHist.append(thisVersion)
			versionLaunchCts[thisVersion] = 0
			versionFirstLaunchDts[thisVersion] = dateNow
		}
		versionLaunchCts[thisVersion] = (versionLaunchCts[thisVersion] ?? 0) + 1
		versionLastLaunchDts[thisVersion] = dateNow
		history[Keys.VersionHistory]					= versionHist
		launchCounts[Keys.VersionLaunchCounts]			= versionLaunchCts
		firstLaunchDates[Keys.VersionFirstLaunchDates]	= versionFirstLaunchDts
		lastLaunchDates[Keys.VersionLastLaunchDates]	= versionLastLaunchDts
		
		// Update the build info
		let thisBuild = currentBuild
		var buildHist			= history[Keys.BuildHistory]!
		var buildLaunchCts		= launchCounts[Keys.BuildLaunchCounts]!
		var buildFirstLaunchDts = firstLaunchDates[Keys.BuildFirstLaunchDates]!
		var buildLastLaunchDts	= lastLaunchDates[Keys.BuildLastLaunchDates]!
		if !buildHist.contains(thisBuild) {
			buildHist.append(thisBuild)
			buildLaunchCts[thisBuild] = 0
			buildFirstLaunchDts[thisBuild] = dateNow
		}
		buildLaunchCts[thisBuild] = (buildLaunchCts[thisBuild] ?? 0) + 1
		buildLastLaunchDts[thisBuild] = dateNow
		history[Keys.BuildHistory]						= buildHist
		launchCounts[Keys.BuildLaunchCounts]			= buildLaunchCts
		firstLaunchDates[Keys.BuildFirstLaunchDates]	= buildFirstLaunchDts
		lastLaunchDates[Keys.BuildLastLaunchDates]		= buildLastLaunchDts
		
		// Set the tracker's variables
		tracker.history = history
		tracker.launchCounts = launchCounts
		tracker.firstLaunchDates = firstLaunchDates
		tracker.lastLaunchDates = lastLaunchDates
		
		// Update the defaults
		defaults.set(history, forKey: Keys.History)
		defaults.set(launchCounts, forKey: Keys.LaunchCounts)
		defaults.set(firstLaunchDates, forKey: Keys.FirstLaunchDates)
		defaults.set(lastLaunchDates, forKey: Keys.LastLaunchDates)
		
//		#if DEBUG
//			logVersionInfo()
//		#endif
	}
	
	// MARK: Number of Launches
	
	fileprivate static var isFirstLaunchEver: Bool {
		return (numberOfLaunchesEver == 1)
	}
	
	fileprivate static func isFirstLaunch(for version: AppVersion) -> Bool {
		return (numberOfLaunches(for: version) == 1)
	}
	
	fileprivate static func isFirstLaunch(for build: AppBuild) -> Bool {
		return (numberOfLaunches(for: build) == 1)
	}
	
	fileprivate static var numberOfLaunchesEver: Int {
		return tracker.totalLaunchCount
	}
	
	fileprivate static func numberOfLaunches(for version: AppVersion) -> Int {
		return tracker.launchCounts[Keys.VersionLaunchCounts]?[version.versionString] ?? 0
	}
	
	fileprivate static func numberOfLaunches(for build: AppBuild) -> Int {
		return tracker.launchCounts[Keys.BuildLaunchCounts]?[build.versionString] ?? 0
	}
	
	// MARK: Launch Dates
	
	fileprivate static var dateOfFirstLaunchEver: Date {
		return tracker.firstEverLaunchDate
	}
	
	fileprivate static func dateOfFirstLaunch(for version: AppVersion) -> Date? {
		return tracker.firstLaunchDates[Keys.VersionFirstLaunchDates]![version.versionString]
	}
	
	fileprivate static func dateOfFirstLaunch(for build: AppBuild) -> Date? {
		return tracker.firstLaunchDates[Keys.BuildFirstLaunchDates]![build.versionString]
	}
	
	fileprivate static func dateOfLastLaunch(for version: AppVersion) -> Date? {
		return tracker.lastLaunchDates[Keys.VersionLastLaunchDates]![version.versionString]
	}
	
	fileprivate static func dateOfLastLaunch(for build: AppBuild) -> Date? {
		return tracker.lastLaunchDates[Keys.BuildLastLaunchDates]![build.versionString]
	}
	
	// MARK: Getting Versions & Builds
	
	fileprivate static var currentVersion: String {
		return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	fileprivate static var previousVersion: String? {
		let versions = versionHistory
		return versions.count > 1 ? versions[versions.count - 2] : nil
	}
	
	fileprivate static var versionHistory: [String] {
		return tracker.history[Keys.VersionHistory]!
	}
	
	fileprivate static var currentBuild: String {
		return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
	}
	
	fileprivate static var previousBuild: String? {
		let builds = buildHistory
		return builds.count > 1 ? builds[builds.count - 2] : nil
	}
	
	fileprivate static var buildHistory: [String] {
		return tracker.history[Keys.BuildHistory]!
	}
}

// MARK: Helpers

private extension AppVersionTracker {
	
	/// Prints a summary of the current version and build information to the
	/// log.
	static func logVersionInfo() {
		print("========= Version Info =========")
		print("Current Version: \(AppVersion.current)")
		print("Current Build: \(AppBuild.current)")
		if isFirstLaunchEver {
			print("First launch ever.")
		} else if isFirstLaunch(for: AppVersion.current) {
			print("First launch of this version.")
		} else {
			print("\(numberOfLaunches(for: AppVersion.current)) launches of this version.")
			if isFirstLaunch(for: AppBuild.current) {
				print("First launch of this build.")
			} else {
				print("\(numberOfLaunches(for: AppBuild.current)) launches of this build.")
			}
		}
		print("================================")
	}
}

// MARK: - VersionRepresentable

public protocol VersionRepresentable: ExpressibleByStringLiteral, CustomStringConvertible, CustomDebugStringConvertible, Comparable {
	init(_ versionString: String)
	var versionString: String { get }
}

public func <<V: VersionRepresentable>(lhs: V, rhs: V) -> Bool {
	return lhs.versionString.compare(rhs.versionString, options: .numeric) == .orderedAscending
}

public func ==<V: VersionRepresentable>(lhs: V, rhs: V) -> Bool {
	return lhs.versionString.compare(rhs.versionString, options: .numeric) == .orderedSame
}

public extension VersionRepresentable {
	
	init(stringLiteral value: String) {
		self.init(value)
	}
	
	init(extendedGraphemeClusterLiteral value: String) {
		self.init(value)
	}
	
	init(unicodeScalarLiteral value: String) {
		self.init(value)
	}
	
	var description: String {
		return versionString
	}
	
	var debugDescription: String {
		return versionString
	}
}

// MARK: - System Version

public struct SystemVersion: VersionRepresentable {
	
	// MARK: Properties
	
	public var versionString: String
	
	// MARK: Lifecycle
	
	public init(_ versionString: String) {
		self.versionString = versionString
	}
	
	// MARK: Getting Versions
	
	public static var current = SystemVersion(UIDevice.current.systemVersion)
}

// MARK: - AppVersion

public struct AppVersion: VersionRepresentable {
	
	// MARK: Properties
	
	public var versionString: String
	
	// MARK: Lifecycle
	
	public init(_ versionString: String) {
		self.versionString = versionString
	}
	
	// MARK: Tracking App Launches
	
	/// Call each time the app is launched.
	public static func trackLaunch() {
		AppVersionTracker.track()
	}
	
	// MARK: Getting Versions
	
	public static var current = AppVersion(AppVersionTracker.currentVersion)
	
	public static var previous: AppVersion? = {
		if let previousVersionString = AppVersionTracker.previousVersion {
			return AppVersion(previousVersionString)
		} else {
			return nil
		}
	}()
	
	public static var history = AppVersionTracker.versionHistory.map(AppVersion.init)
	
	// MARK: Number of Launches
	
	public static var isFirstLaunchEver: Bool {
		return AppVersionTracker.isFirstLaunchEver
	}
	
	public var isFirstLaunch: Bool {
		return AppVersionTracker.isFirstLaunch(for: self)
	}
	
	public var numberOfLaunches: Int {
		return AppVersionTracker.numberOfLaunches(for: self)
	}
	
	// MARK: Launch Dates
	
	public static var dateOfFirstLaunchEver: Date {
		return AppVersionTracker.dateOfFirstLaunchEver
	}
	
	public var dateOfFirstLaunch: Date? {
		return AppVersionTracker.dateOfFirstLaunch(for: self)
	}
	
	public var dateOfLastLaunch: Date? {
		return AppVersionTracker.dateOfLastLaunch(for: self)
	}
}

// MARK: - AppBuild

public struct AppBuild: VersionRepresentable {
	
	// MARK: Properties
	
	public var versionString: String
	
	// MARK: Lifecycle
	
	public init(_ versionString: String) {
		self.versionString = versionString
	}
	
	// MARK: Getting Versions
	
	public static var current = AppBuild(AppVersionTracker.currentBuild)
	
	public static var previous: AppBuild? = {
		if let previousVersionString = AppVersionTracker.previousBuild {
			return AppBuild(previousVersionString)
		} else {
			return nil
		}
	}()
	
	public static var history = AppVersionTracker.buildHistory.map(AppBuild.init)
	
	// MARK: Number of Launches
	
	public static var isFirstLaunchEver: Bool {
		return AppVersionTracker.isFirstLaunchEver
	}
	
	public var isFirstLaunch: Bool {
		return AppVersionTracker.isFirstLaunch(for: self)
	}
	
	public var numberOfLaunches: Int {
		return AppVersionTracker.numberOfLaunches(for: self)
	}
	
	// MARK: Launch Dates
	
	public static var dateOfFirstLaunchEver: Date {
		return AppVersionTracker.dateOfFirstLaunchEver
	}
	
	public var dateOfFirstLaunch: Date? {
		return AppVersionTracker.dateOfFirstLaunch(for: self)
	}
	
	public var dateOfLastLaunch: Date? {
		return AppVersionTracker.dateOfLastLaunch(for: self)
	}
}
