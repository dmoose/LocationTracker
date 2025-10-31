//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Cascade on 2025-06-23.
//

import Foundation
import CoreLocation
import Observation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker {
    public enum LocationError: Error, LocalizedError, Identifiable {
        case authorizationDenied
        case authorizationRestricted
        case locationUnavailable
        case unknown

        public var id: String { localizedDescription }

        public var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "Location access was denied by the user."
            case .authorizationRestricted:
                return "Location access is restricted and cannot be requested."
            case .locationUnavailable:
                return "Location information is currently unavailable."
            case .unknown:
                return "An unknown location error occurred."
            }
        }
    }

    @Observable
    public class LocationManager: NSObject, CLLocationManagerDelegate {
        private let locationManager = CLLocationManager()
        private let historyProvider: LocationHistoryProvider

        @MainActor public private(set) var currentLocation: Location?
        @MainActor public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
        @MainActor public private(set) var lastError: LocationError?

        private var locationContinuation: CheckedContinuation<Location, Error>?
        private let continuationLock = NSLock()

        public init(historyProvider: LocationHistoryProvider = .shared) {
            self.historyProvider = historyProvider
            super.init()
            locationManager.delegate = self
            // The initial value is .notDetermined, now fetch the real one.
            Task { @MainActor in
                self.authorizationStatus = CLLocationManager().authorizationStatus
            }
        }

        @MainActor
        public func requestPermission() {
            guard locationManager.authorizationStatus == .notDetermined else { return }
            locationManager.requestWhenInUseAuthorization()
        }

        public func startUpdatingLocation(accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance = kCLDistanceFilterNone, allowsBackgroundUpdates: Bool = false) {
            locationManager.desiredAccuracy = accuracy
            locationManager.distanceFilter = distanceFilter
            locationManager.allowsBackgroundLocationUpdates = allowsBackgroundUpdates
            locationManager.startUpdatingLocation()
        }

        public func stopUpdatingLocation() {
            locationManager.stopUpdatingLocation()
        }

        // MARK: - Power/Behavior Configuration

        /// The type of user activity associated with the location updates.
        /// Helps the system optimize power and accuracy trade-offs.
        public var activityType: CLActivityType {
            get { locationManager.activityType }
            set { locationManager.activityType = newValue }
        }

        /// Whether the location manager may pause updates to save power.
        /// iOS only.
        #if os(iOS)
        public var pausesLocationUpdatesAutomatically: Bool {
            get { locationManager.pausesLocationUpdatesAutomatically }
            set { locationManager.pausesLocationUpdatesAutomatically = newValue }
        }

        /// Whether to show the blue background location indicator when updating in the background.
        public var showsBackgroundLocationIndicator: Bool {
            get { locationManager.showsBackgroundLocationIndicator }
            set { locationManager.showsBackgroundLocationIndicator = newValue }
        }
        #endif

        public func enableBackgroundUpdates(_ allows: Bool) {
            locationManager.allowsBackgroundLocationUpdates = allows
        }

        /// Start monitoring for significant changes in the user’s location.
        /// This is a low-power alternative to continuous updates.
        @MainActor public private(set) var isMonitoringSignificantChanges: Bool = false

        public func startSignificantChangeUpdates() {
            locationManager.startMonitoringSignificantLocationChanges()
            Task { @MainActor in self.isMonitoringSignificantChanges = true }
        }

        /// Stop monitoring significant changes.
        public func stopSignificantChangeUpdates() {
            locationManager.stopMonitoringSignificantLocationChanges()
            Task { @MainActor in self.isMonitoringSignificantChanges = false }
        }

        @MainActor
        public func getHistory() -> [Location] {
            historyProvider.getHistory()
        }

        @MainActor
        public func clearHistory() {
            historyProvider.clearHistory()
        }

        public func getCurrentLocation() async throws -> Location {
            let status = await authorizationStatus
            guard status != .denied && status != .restricted else {
                let error: LocationError = (status == .restricted) ? .authorizationRestricted : .authorizationDenied
                await MainActor.run { self.lastError = error }
                throw error
            }

            return try await withCheckedThrowingContinuation { continuation in
                continuationLock.withLock {
                    self.locationContinuation = continuation
                }
                locationManager.requestLocation()
            }
        }

        // MARK: - CLLocationManagerDelegate

        nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let clLocation = locations.last else { return }
            let newLocation = Location(from: clLocation)

            Task { @MainActor in
                self.currentLocation = newLocation
                self.historyProvider.addLocation(newLocation)
                self.lastError = nil
            }

            continuationLock.withLock {
                if let continuation = self.locationContinuation {
                    continuation.resume(returning: newLocation)
                    self.locationContinuation = nil
                }
            }
        }

        nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            let locationError: LocationError
            if let clError = error as? CLError, clError.code == .denied {
                locationError = .authorizationDenied
            } else {
                locationError = .locationUnavailable
            }

            Task { @MainActor in
                self.lastError = locationError
            }

            continuationLock.withLock {
                if let continuation = self.locationContinuation {
                    continuation.resume(throwing: locationError)
                    self.locationContinuation = nil
                }
            }
        }

        nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let newStatus = manager.authorizationStatus
            Task { @MainActor in
                self.authorizationStatus = newStatus
                switch newStatus {
                case .denied:
                    self.lastError = .authorizationDenied
                case .restricted:
                    self.lastError = .authorizationRestricted
                case .authorizedWhenInUse, .authorizedAlways:
                    if self.lastError == .authorizationDenied || self.lastError == .authorizationRestricted {
                        self.lastError = nil
                    }
                default:
                    break
                }
            }
        }
    }
}
