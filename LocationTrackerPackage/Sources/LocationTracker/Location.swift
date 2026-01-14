//
//  Location.swift
//  LocationTracker
//
//  Created by Cascade on 2025-06-23.
//

import Foundation
import CoreLocation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker {
    /// A simple data structure to represent a geographical location.
    public struct Location: Codable, Equatable, Identifiable, Sendable {
        public let id: UUID
        public let latitude: Double
        public let longitude: Double
        public let timestamp: Date

        public init(id: UUID = UUID(), latitude: Double, longitude: Double, timestamp: Date) {
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.timestamp = timestamp
        }

        internal init(from clLocation: CLLocation) {
            self.init(
                latitude: clLocation.coordinate.latitude,
                longitude: clLocation.coordinate.longitude,
                timestamp: clLocation.timestamp
            )
        }
    }
}
