//
//  Geocoder.swift
//  LocationTracker
//
//  Optional reverse geocoding helper utilities.
//

import Foundation
import CoreLocation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension LocationTracker {
    enum Geocoder {
        /// Reverse geocode a Location to the first CLPlacemark (if any).
        /// - Parameters:
        ///   - location: The Location to reverse.
        ///   - preferredLocale: Optional locale to influence the returned fields.
        /// - Returns: The first CLPlacemark or nil if none.
        public static func reverse(location: Location, preferredLocale: Locale? = nil) async throws -> CLPlacemark? {
            let geocoder = CLGeocoder()
            let cl = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let placemarks = try await geocoder.reverseGeocodeLocation(cl, preferredLocale: preferredLocale)
            return placemarks.first
        }

        /// Produce a concise, user-friendly string for display from a placemark.
        /// Tries common components and degrades gracefully.
        public static func format(placemark: CLPlacemark) -> String {
            // Prefer locality + admin area + country (e.g., "Cupertino, CA, United States")
            var parts: [String] = []
            if let locality = placemark.locality, !locality.isEmpty { parts.append(locality) }
            if let admin = placemark.administrativeArea, !admin.isEmpty { parts.append(admin) }
            if let country = placemark.country, !country.isEmpty { parts.append(country) }
            if !parts.isEmpty { return parts.joined(separator: ", ") }

            // Fallbacks
            if let name = placemark.name, !name.isEmpty { return name }
            if let thoroughfare = placemark.thoroughfare, !thoroughfare.isEmpty { return thoroughfare }
            return "Unknown place"
        }
    }
}

