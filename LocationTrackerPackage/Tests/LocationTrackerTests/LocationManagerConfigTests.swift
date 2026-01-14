//
//  LocationManagerConfigTests.swift
//  LocationTrackerTests
//
//  Tests for configuration properties exposed by LocationManager
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class LocationManagerConfigTests: XCTestCase {
    func testActivityTypeSetAndGet() async {
        let manager = await LocationTracker.LocationManager()
        await MainActor.run {
            manager.activityType = .fitness
            XCTAssertEqual(manager.activityType, .fitness)
        }
    }

    #if os(iOS)
    func testPauseAndBackgroundIndicatorSetAndGet_iOS() async {
        let manager = await LocationTracker.LocationManager()
        await MainActor.run {
            manager.pausesLocationUpdatesAutomatically = false
            manager.showsBackgroundLocationIndicator = true
            XCTAssertFalse(manager.pausesLocationUpdatesAutomatically)
            XCTAssertTrue(manager.showsBackgroundLocationIndicator)
        }
    }
    #endif
}

