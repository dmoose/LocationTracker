//
//  LocationTests.swift
//  LocationTrackerTests
//
//  Deterministic tests for Location value semantics
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class LocationTests: XCTestCase {
    func testInitFromCLLocationCopiesFields() {
        // Use a fixed time for assertion
        let timestamp = Date(timeIntervalSince1970: 1_725_000_000)
        let cl = CLLocation(coordinate: .init(latitude: 37.3318, longitude: -122.0312),
                            altitude: 0,
                            horizontalAccuracy: 5,
                            verticalAccuracy: 5,
                            timestamp: timestamp)

        let loc = LocationTracker.Location(from: cl)

        XCTAssertEqual(loc.latitude, cl.coordinate.latitude, accuracy: 1e-9)
        XCTAssertEqual(loc.longitude, cl.coordinate.longitude, accuracy: 1e-9)
        XCTAssertEqual(loc.timestamp.timeIntervalSince1970, timestamp.timeIntervalSince1970, accuracy: 0.001)
    }
}

