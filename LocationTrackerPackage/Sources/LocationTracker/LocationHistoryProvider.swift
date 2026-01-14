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
    @MainActor
    public class LocationHistoryProvider {
        public static let shared = LocationHistoryProvider()

        private var history: [Location] = []

        // Retention controls (optional)
        private var _maxEntries: Int? = nil
        private var _maxAge: TimeInterval? = nil

        /// Maximum number of entries to retain. Oldest entries are trimmed first.
        /// Set to `nil` (default) for no limit.
        ///
        /// Trimming occurs after appends and also when reading history, ensuring the returned
        /// snapshot respects the current limit without requiring a manual cleanup call.
        public var maxEntries: Int? {
            get { _maxEntries }
            set {
                _maxEntries = newValue
                trimIfNeeded(now: Date())
            }
        }

        /// Maximum age (in seconds) to retain entries. Older entries are dropped.
        /// Set to `nil` (default) for no limit.
        ///
        /// Age-based trimming uses each entry's `timestamp` and applies both after appends and on read.
        /// Combined with `maxEntries`, the final history contains only recent items within both limits.
        public var maxAge: TimeInterval? {
            get { _maxAge }
            set {
                _maxAge = newValue
                trimIfNeeded(now: Date())
            }
        }

        public init(maxEntries: Int? = nil, maxAge: TimeInterval? = nil) {
            self._maxEntries = maxEntries
            self._maxAge = maxAge
        }

        /// Adds a new location to the history.
        /// - Parameter location: The `Location` to add.
        public func addLocation(_ location: Location) {
            history.append(location)
            trimIfNeeded(now: Date())
        }

        /// Retrieves the entire location history.
        /// - Returns: An array of `Location` objects.
        public func getHistory() -> [Location] {
            // Apply age-based trimming at read time as well
            trimIfNeeded(now: Date())
            return history
        }

        /// Clears all locations from the history.
        public func clearHistory() {
            history.removeAll()
        }

        // MARK: - Trimming
        private func trimIfNeeded(now: Date) {
            // Age-based trimming
            if let maxAge = _maxAge {
                let cutoff = now.addingTimeInterval(-maxAge)
                if let idx = history.firstIndex(where: { $0.timestamp >= cutoff }) {
                    if idx > 0 { history.removeFirst(idx) }
                } else {
                    // All entries older than cutoff
                    history.removeAll()
                }
            }
            // Count-based trimming
            if let maxEntries = _maxEntries, maxEntries >= 0, history.count > maxEntries {
                history = Array(history.suffix(maxEntries))
            }
        }
    }
}
