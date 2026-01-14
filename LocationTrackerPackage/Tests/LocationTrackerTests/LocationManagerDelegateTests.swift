//
//  LocationManagerDelegateTests.swift
//  LocationTrackerTests
//
//  Tests simulate delegate callbacks without using real Core Location
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class LocationManagerDelegateTests: XCTestCase {
    func testDidUpdateLocationsSetsStateAndHistory() async {
        let manager = await LocationTracker.LocationManager()
        let cl = CLLocation(latitude: 10.0, longitude: 20.0)

        // Simulate delegate callback
        manager.locationManager(CLLocationManager(), didUpdateLocations: [cl])

        // Assert on main actor
        await MainActor.run {
            XCTAssertNotNil(manager.currentLocation)
            XCTAssertNil(manager.lastError)
            let history = manager.getHistory()
            XCTAssertEqual(history.last!.latitude, 10.0, accuracy: 1e-9)
            XCTAssertEqual(history.last!.longitude, 20.0, accuracy: 1e-9)
        }
    }

    func testDidFailWithErrorDeniedSetsAuthorizationDenied() async {
        let manager = await LocationTracker.LocationManager()
        let err = CLError(.denied)
        manager.locationManager(CLLocationManager(), didFailWithError: err)

        await MainActor.run {
            XCTAssertEqual(manager.lastError, .authorizationDenied)
        }
    }

    func testDidFailWithErrorGenericSetsLocationUnavailable() async {
        let manager = await LocationTracker.LocationManager()
        // Use a non-denied error, e.g., network
        let err = CLError(.network)
        manager.locationManager(CLLocationManager(), didFailWithError: err)

        await MainActor.run {
            XCTAssertEqual(manager.lastError, .locationUnavailable)
        }
    }
}

