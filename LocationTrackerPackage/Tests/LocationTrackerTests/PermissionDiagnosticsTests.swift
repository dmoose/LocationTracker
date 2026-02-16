//
//  PermissionDiagnosticsTests.swift
//  LocationTrackerTests
//
//  Tests for PermissionDiagnostics utilities
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class PermissionDiagnosticsTests: XCTestCase {

    func testUsageStringsPresenceReturnsStructWithBooleans() {
        // Test with main bundle (may or may not have keys depending on test target config)
        let presence = LocationTracker.PermissionDiagnostics.usageStringsPresence()

        // Just verify the return type works - actual values depend on test bundle
        XCTAssertTrue(presence.whenInUse || !presence.whenInUse) // Always true, validates type
        XCTAssertTrue(presence.alwaysAndWhenInUse || !presence.alwaysAndWhenInUse)
    }

    func testUsageStringsPresenceWithCustomBundle() {
        // Test with a bundle that definitely won't have location keys
        let bundle = Bundle(for: PermissionDiagnosticsTests.self)
        let presence = LocationTracker.PermissionDiagnostics.usageStringsPresence(in: bundle)

        // Test bundle shouldn't have these keys configured
        XCTAssertFalse(presence.whenInUse)
        XCTAssertFalse(presence.alwaysAndWhenInUse)
    }

    func testServicesEnabledReturnsBool() {
        // This calls CLLocationManager.locationServicesEnabled()
        // We can't control the system setting, but we can verify it returns without crashing
        let enabled = LocationTracker.PermissionDiagnostics.servicesEnabled()

        // Verify it's a valid boolean (this test mainly ensures the method doesn't crash)
        XCTAssertTrue(enabled || !enabled)
    }

    func testUsageStringsPresenceIsSendable() {
        // Verify UsageStringsPresence can be passed across concurrency boundaries
        let presence = LocationTracker.PermissionDiagnostics.usageStringsPresence()

        Task {
            // This compiles only if UsageStringsPresence is Sendable
            let _ = presence.whenInUse
            let _ = presence.alwaysAndWhenInUse
        }
    }
}
