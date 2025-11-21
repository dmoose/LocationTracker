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

        // Retention controls (optional)
        private var _maxEntries: Int? = nil
        private var _maxAge: TimeInterval? = nil

        /// Maximum number of entries to retain. Oldest entries are trimmed first.
        /// Set to nil (default) for no limit.
        public var maxEntries: Int? {
            get { queue.sync { _maxEntries } }
            set { queue.async { self._maxEntries = newValue; self.trimIfNeeded_locked(now: Date()) } }
        }

        /// Maximum age (in seconds) to retain entries. Older entries are dropped.
        /// Set to nil (default) for no limit.
        public var maxAge: TimeInterval? {
            get { queue.sync { _maxAge } }
            set { queue.async { self._maxAge = newValue; self.trimIfNeeded_locked(now: Date()) } }
        }

        public init(maxEntries: Int? = nil, maxAge: TimeInterval? = nil) {
            self._maxEntries = maxEntries
            self._maxAge = maxAge
        }

        /// Adds a new location to the history.
        /// - Parameter location: The `Location` to add.
        public func addLocation(_ location: Location) {
            queue.async {
                self.history.append(location)
                self.trimIfNeeded_locked(now: Date())
            }
        }

        /// Retrieves the entire location history.
        /// - Returns: An array of `Location` objects.
        public func getHistory() -> [Location] {
            queue.sync {
                // Apply age-based trimming at read time as well
                self.trimIfNeeded_locked(now: Date())
                return self.history
            }
        }

        /// Clears all locations from the history.
        public func clearHistory() {
            queue.async {
                self.history.removeAll()
            }
        }

        // MARK: - Trimming
        private func trimIfNeeded_locked(now: Date) {
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
