//
//  LocationHistoryProvider.swift
//  LocationTracker
//
//  Created by Cascade on 2025-06-23.
//

import Foundation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker {
    /// An in-memory provider for storing and retrieving location history.
    public class LocationHistoryProvider {
        public static let shared = LocationHistoryProvider()

        private var history: [Location] = []
        private let queue = DispatchQueue(label: "com.locationtracker.history.queue")

        public init() {}

        /// Adds a new location to the history.
        /// - Parameter location: The `Location` to add.
        public func addLocation(_ location: Location) {
            queue.async {
                self.history.append(location)
            }
        }

        /// Retrieves the entire location history.
        /// - Returns: An array of `Location` objects.
        public func getHistory() -> [Location] {
            queue.sync {
                self.history
            }
        }

        /// Clears all locations from the history.
        public func clearHistory() {
            queue.async {
                self.history.removeAll()
            }
        }
    }
}
