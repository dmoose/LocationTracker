//
//  GeocoderTests.swift
//  LocationTrackerTests
//
//  Tests for Geocoder formatting utilities
//

import XCTest
@testable import LocationTracker
import CoreLocation

final class GeocoderTests: XCTestCase {

    // MARK: - format() Tests

    func testFormatWithLocalityAdminAndCountry() {
        let placemark = MockPlacemark(
            locality: "Cupertino",
            administrativeArea: "CA",
            country: "United States"
        )

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Cupertino, CA, United States")
    }

    func testFormatWithLocalityOnly() {
        let placemark = MockPlacemark(locality: "London")

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "London")
    }

    func testFormatWithAdminAndCountryOnly() {
        let placemark = MockPlacemark(
            administrativeArea: "Queensland",
            country: "Australia"
        )

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Queensland, Australia")
    }

    func testFormatFallsBackToName() {
        let placemark = MockPlacemark(name: "Golden Gate Bridge")

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Golden Gate Bridge")
    }

    func testFormatFallsBackToThoroughfare() {
        let placemark = MockPlacemark(thoroughfare: "Market Street")

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Market Street")
    }

    func testFormatReturnsUnknownPlaceWhenEmpty() {
        let placemark = MockPlacemark()

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Unknown place")
    }

    func testFormatIgnoresEmptyStrings() {
        let placemark = MockPlacemark(
            locality: "",
            administrativeArea: "",
            country: "",
            name: "Actual Name"
        )

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "Actual Name")
    }

    func testFormatPrefersLocalityOverName() {
        let placemark = MockPlacemark(
            locality: "San Francisco",
            name: "Some Landmark"
        )

        let result = LocationTracker.Geocoder.format(placemark: placemark)
        XCTAssertEqual(result, "San Francisco")
    }
}

// MARK: - Mock Placemark

/// A subclass of CLPlacemark that allows setting properties for testing.
/// CLPlacemark's properties are read-only, so we override them.
private final class MockPlacemark: CLPlacemark, @unchecked Sendable {
    private var _locality: String?
    private var _administrativeArea: String?
    private var _country: String?
    private var _name: String?
    private var _thoroughfare: String?

    init(
        locality: String? = nil,
        administrativeArea: String? = nil,
        country: String? = nil,
        name: String? = nil,
        thoroughfare: String? = nil
    ) {
        self._locality = locality
        self._administrativeArea = administrativeArea
        self._country = country
        self._name = name
        self._thoroughfare = thoroughfare

        // CLPlacemark requires initialization with a placemark
        // We use a minimal approach with MKPlacemark
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let mkPlacemark = MKPlacemark(coordinate: coordinate)
        super.init(placemark: mkPlacemark)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented for mock")
    }

    override var locality: String? { _locality }
    override var administrativeArea: String? { _administrativeArea }
    override var country: String? { _country }
    override var name: String? { _name }
    override var thoroughfare: String? { _thoroughfare }
}

#if canImport(MapKit)
import MapKit
#endif
