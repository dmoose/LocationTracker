//
//  HistoryRetentionTests.swift
//  LocationTrackerTests
//
//  Tests for maxEntries and maxAge trimming in LocationHistoryProvider
//

import XCTest
@testable import LocationTracker

final class HistoryRetentionTests: XCTestCase {
    func testMaxEntriesTrimmingKeepsMostRecent() {
        let provider = LocationTracker.LocationHistoryProvider()
        provider.maxEntries = 3

        let now = Date()
        let items: [LocationTracker.Location] = (0..<5).map { i in
            .init(latitude: Double(i), longitude: Double(i), timestamp: now.addingTimeInterval(Double(i)))
        }
        items.forEach { provider.addLocation($0) }

        // Allow async queue to flush
        let exp = expectation(description: "flush")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        let hist = provider.getHistory()
        XCTAssertEqual(hist.count, 3)
        XCTAssertEqual(hist[0].latitude, 2)
        XCTAssertEqual(hist[1].latitude, 3)
        XCTAssertEqual(hist[2].latitude, 4)
    }

    func testMaxAgeTrimmingDropsOldEntries() {
        let provider = LocationTracker.LocationHistoryProvider()
        provider.maxAge = 0.5 // 0.5s

        let now = Date()
        let old = LocationTracker.Location(latitude: 0, longitude: 0, timestamp: now.addingTimeInterval(-10))
        let recent = LocationTracker.Location(latitude: 1, longitude: 1, timestamp: now)

        provider.addLocation(old)
        provider.addLocation(recent)

        // Allow async queue to flush
        let exp = expectation(description: "flush")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        let hist = provider.getHistory()
        XCTAssertEqual(hist.count, 1)
        XCTAssertEqual(hist[0].latitude, 1)
    }
}

