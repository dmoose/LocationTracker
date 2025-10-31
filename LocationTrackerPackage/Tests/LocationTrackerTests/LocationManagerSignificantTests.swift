//
//  LocationManagerSignificantTests.swift
//  LocationTrackerTests
//
//  Verify significant-change state tracking toggles
//

import XCTest
@testable import LocationTracker

final class LocationManagerSignificantTests: XCTestCase {
    func testSignificantChangeStateToggles() async {
        let manager = LocationTracker.LocationManager()
        await MainActor.run {
            XCTAssertFalse(manager.isMonitoringSignificantChanges)
        }

        manager.startSignificantChangeUpdates()
        await MainActor.run {
            XCTAssertTrue(manager.isMonitoringSignificantChanges)
        }

        manager.stopSignificantChangeUpdates()
        await MainActor.run {
            XCTAssertFalse(manager.isMonitoringSignificantChanges)
        }
    }
}

