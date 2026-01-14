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
        let manager = await LocationTracker.LocationManager()
        await MainActor.run {
            XCTAssertFalse(manager.isMonitoringSignificantChanges)
        }

        await manager.startSignificantChangeUpdates()
        await MainActor.run {
            XCTAssertTrue(manager.isMonitoringSignificantChanges)
        }

        await manager.stopSignificantChangeUpdates()
        await MainActor.run {
            XCTAssertFalse(manager.isMonitoringSignificantChanges)
        }
    }
}

