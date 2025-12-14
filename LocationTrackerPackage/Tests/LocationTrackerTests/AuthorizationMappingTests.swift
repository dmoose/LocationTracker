//
//  AuthorizationMappingTests.swift
//  LocationTrackerTests
//
//  Verify platform-agnostic Authorization mapping
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class AuthorizationMappingTests: XCTestCase {
    #if os(iOS)
    func testIOSMapping() {
        XCTAssertEqual(LocationTracker.Authorization(.notDetermined), .notDetermined)
        XCTAssertEqual(LocationTracker.Authorization(.restricted), .restricted)
        XCTAssertEqual(LocationTracker.Authorization(.denied), .denied)
        XCTAssertEqual(LocationTracker.Authorization(.authorizedWhenInUse), .authorizedWhenInUse)
        XCTAssertEqual(LocationTracker.Authorization(.authorizedAlways), .authorizedAlways)
    }
    #endif

    #if os(macOS)
    func testMacOSMapping() {
        XCTAssertEqual(LocationTracker.Authorization(.notDetermined), .notDetermined)
        XCTAssertEqual(LocationTracker.Authorization(.restricted), .restricted)
        XCTAssertEqual(LocationTracker.Authorization(.denied), .denied)
        XCTAssertEqual(LocationTracker.Authorization(.authorized), .authorized)
    }
    #endif
}

