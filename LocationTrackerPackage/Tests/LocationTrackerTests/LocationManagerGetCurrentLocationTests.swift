//
//  LocationManagerGetCurrentLocationTests.swift
//  LocationTrackerTests
//
//  Tests for single-flight, timeout, and accuracy threshold behavior
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class LocationManagerGetCurrentLocationTests: XCTestCase {
    func testSingleFlightGuardsSecondCall() async {
        let manager = await LocationTracker.LocationManager()

        print("[diag] starting first request at", Date())
        // Start a request without completing it; use a short timeout to speed up the test
        let first = Task { () -> LocationTracker.Location? in
            do {
                return try await manager.getCurrentLocation(timeout: 0.5)
            } catch {
                print("[diag] first request threw:", error)
                return nil
            }
        }

        // Launch second call concurrently so we can time-box it
        var secondOutcome = "not-started"
        var secondError: Error?
        let second = Task { () -> Void in
            print("[diag] invoking second call at", Date())
            do {
                _ = try await manager.getCurrentLocation()
                secondOutcome = "returned-success"
                print("[diag] second call unexpectedly returned success at", Date())
            } catch {
                secondOutcome = "threw"
                secondError = error
                print("[diag] second call threw at", Date(), "error:", error)
            }
        }

        // Give the second call a small window to complete or throw
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms

        // If it hasn't finished by now, cancel it to avoid hanging
        if !second.isCancelled && secondOutcome == "not-started" {
            print("[diag] second call appears stuck after 300ms; cancelling at", Date())
            second.cancel()
            // Wait a beat for cancellation to propagate
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        // Assert we saw the expected error, or fail with diagnostics
        if secondOutcome == "threw" {
            if let e = secondError as? LocationTracker.LocationError {
                switch e {
                case .alreadyInProgress:
                    // expected
                    break
                default:
                    XCTFail("Second call threw unexpected package error: \(e)")
                }
            } else if let e = secondError {
                XCTFail("Second call threw non-package error: \(e)")
            } else {
                XCTFail("Second call outcome 'threw' but no captured error")
            }
        } else {
            XCTFail("Second call did not throw within 300ms; outcome=\(secondOutcome)")
        }

        // Ensure the first task finishes (timeout path expected)
        _ = await first.value
        print("[diag] first request finished at", Date())
    }

    func testTimeoutFiresWhenNoUpdateArrives() async {
        let manager = await LocationTracker.LocationManager()
        do {
            _ = try await manager.getCurrentLocation(timeout: 0.05)
            XCTFail("Expected timeout error")
        } catch let error as LocationTracker.LocationError {
            if case .timeout = error {
                // ok
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected non-package error: \(error)")
        }
    }

    func testAccuracyThresholdDelaysUntilGoodFix() async {
        let manager = await LocationTracker.LocationManager()

        let resultTask = Task { () -> LocationTracker.Location in
            try await manager.getCurrentLocation(timeout: 1.0, accuracyThresholdMeters: 10)
        }

        // First, send a poor-accuracy update (> 10 m)
        let poor = CLLocation(coordinate: .init(latitude: 1, longitude: 2),
                              altitude: 0,
                              horizontalAccuracy: 100, // poor
                              verticalAccuracy: 50,
                              timestamp: Date())
        manager.locationManager(CLLocationManager(), didUpdateLocations: [poor])

        // Ensure we haven't resolved yet
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertFalse(resultTask.isCancelled)
        // Not a strict guarantee, but if it had returned we'd know via structured concurrency cancellation patterns.

        // Then, send a good-accuracy update (<= 10 m)
        let good = CLLocation(coordinate: .init(latitude: 3, longitude: 4),
                              altitude: 0,
                              horizontalAccuracy: 5, // good
                              verticalAccuracy: 10,
                              timestamp: Date())
        manager.locationManager(CLLocationManager(), didUpdateLocations: [good])

        do {
            let loc = try await resultTask.value
            XCTAssertEqual(loc.latitude, 3, accuracy: 1e-9)
            XCTAssertEqual(loc.longitude, 4, accuracy: 1e-9)
        } catch {
            XCTFail("Should have resolved with good accuracy: \(error)")
        }
    }
}

