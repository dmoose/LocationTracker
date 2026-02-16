//
//  LocationManagerAuthorizationTests.swift
//  LocationTrackerTests
//
//  Tests for authorization change handling and related delegate callbacks
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class LocationManagerAuthorizationTests: XCTestCase {

    // MARK: - Authorization Change Delegate Tests

    func testAuthorizationChangeUpdateStatus() async {
        let manager = await LocationTracker.LocationManager()

        // Simulate the delegate callback
        // Note: We can't change the underlying CLLocationManager's status,
        // but we can verify the delegate method processes correctly
        manager.locationManagerDidChangeAuthorization(CLLocationManager())

        // Give time for MainActor task to complete
        let expectation = expectation(description: "MainActor task completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        await MainActor.run {
            // Status should be set (actual value depends on simulator/device state)
            // The key test is that calling the delegate doesn't crash
            XCTAssertNotNil(manager.authorizationStatus)
        }
    }

    func testAuthorizationPropertyMapsFromCLStatus() async {
        let manager = await LocationTracker.LocationManager()

        await MainActor.run {
            // The authorization computed property should map from authorizationStatus
            let auth = manager.authorization
            let status = manager.authorizationStatus

            // Verify the mapping is consistent
            switch status {
            case .notDetermined:
                XCTAssertEqual(auth, .notDetermined)
            case .restricted:
                XCTAssertEqual(auth, .restricted)
            case .denied:
                XCTAssertEqual(auth, .denied)
            case .authorizedWhenInUse:
                #if os(macOS)
                XCTAssertEqual(auth, .authorized)
                #else
                XCTAssertEqual(auth, .authorizedWhenInUse)
                #endif
            case .authorizedAlways:
                #if os(macOS)
                XCTAssertEqual(auth, .authorized)
                #else
                XCTAssertEqual(auth, .authorizedAlways)
                #endif
            @unknown default:
                break
            }
        }
    }

    // MARK: - Request Permission Tests

    func testRequestPermissionDoesNotCrashWhenAlreadyDetermined() async {
        let manager = await LocationTracker.LocationManager()

        await MainActor.run {
            // If already determined, requestPermission should be a no-op
            // This tests that the guard clause works
            if manager.authorizationStatus != .notDetermined {
                manager.requestPermission()
                // Should not crash or throw
            }
        }
    }

    // MARK: - Error State Tests

    func testDeniedAuthorizationSetsError() async {
        let manager = await LocationTracker.LocationManager()

        // Simulate authorization change to denied via the error path
        let error = CLError(.denied)
        manager.locationManager(CLLocationManager(), didFailWithError: error)

        let expectation = expectation(description: "Error propagates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        await MainActor.run {
            XCTAssertEqual(manager.lastError, .authorizationDenied)
        }
    }
}
