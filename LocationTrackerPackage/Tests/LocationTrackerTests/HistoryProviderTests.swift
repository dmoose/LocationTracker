//
//  HistoryProviderTests.swift
//  LocationTrackerTests
//
//  Tests for the in-memory history provider
//

import XCTest
@testable import LocationTracker

final class HistoryProviderTests: XCTestCase {
    func testAddGetClearHistory() {
        let provider = LocationTracker.LocationHistoryProvider()
        XCTAssertTrue(provider.getHistory().isEmpty)

        let l1 = LocationTracker.Location(latitude: 1, longitude: 2, timestamp: Date())
        provider.addLocation(l1)

        // Allow async queue to flush
        let exp = expectation(description: "history updated")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(provider.getHistory().count, 1)
        XCTAssertEqual(provider.getHistory().last!.latitude, 1, accuracy: 1e-9)

        provider.clearHistory()

        // Allow async queue to flush
        let exp2 = expectation(description: "history cleared")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        XCTAssertTrue(provider.getHistory().isEmpty)
    }

    func testConcurrentAddsEventuallyAppear() {
        let provider = LocationTracker.LocationHistoryProvider()
        provider.clearHistory()

        let group = DispatchGroup()
        for i in 0..<20 {
            group.enter()
            DispatchQueue.global().async {
                let loc = LocationTracker.Location(latitude: Double(i), longitude: Double(i), timestamp: Date())
                provider.addLocation(loc)
                group.leave()
            }
        }
        group.wait()

        // Allow async queue to flush
        let exp = expectation(description: "history flushed")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(provider.getHistory().count, 20)
    }
}

