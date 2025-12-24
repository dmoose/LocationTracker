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
        case timeout
        case alreadyInProgress
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
            case .timeout:
                return "Timed out while trying to retrieve the current location."
            case .alreadyInProgress:
                return "A current location request is already in progress."
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
        @MainActor public var authorization: LocationTracker.Authorization { .init(authorizationStatus) }
        @MainActor public private(set) var lastError: LocationError?

        private var locationContinuation: CheckedContinuation<Location, Error>?
        private var pendingAccuracyThresholdMeters: CLLocationAccuracy?
        private var pendingTimeoutTask: Task<Void, Never>?
        private var isCurrentLocationRequestInProgress: Bool = false
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

        public func getCurrentLocation(timeout: TimeInterval? = nil, accuracyThresholdMeters: CLLocationAccuracy? = nil) async throws -> Location {
            // Read authorization directly from the underlying manager to avoid awaiting main actor
            let status = locationManager.authorizationStatus
            if status == .denied || status == .restricted {
                let error: LocationError = (status == .restricted) ? .authorizationRestricted : .authorizationDenied
                await MainActor.run { self.lastError = error }
                throw error
            }

            // Single-flight guard (atomic check-and-set) BEFORE any suspension
            var shouldThrow = false
            continuationLock.withLock {
                if self.isCurrentLocationRequestInProgress || self.locationContinuation != nil {
                    shouldThrow = true
                } else {
                    self.isCurrentLocationRequestInProgress = true
                }
            }
            if shouldThrow {
                throw LocationError.alreadyInProgress
            }

            return try await withCheckedThrowingContinuation { continuation in
                continuationLock.withLock {
                    self.locationContinuation = continuation
                    self.pendingAccuracyThresholdMeters = accuracyThresholdMeters
                    // Cancel any previous timeout task (defensive)
                    self.pendingTimeoutTask?.cancel()
                    if let seconds = timeout, seconds > 0 {
                        let nanos = UInt64(seconds * 1_000_000_000)
                        self.pendingTimeoutTask = Task { [weak self] in
                            try? await Task.sleep(nanoseconds: nanos)
                            guard let self = self else { return }
                            var contToResume: CheckedContinuation<Location, Error>? = nil
                            self.continuationLock.withLock {
                                if let cont = self.locationContinuation {
                                    // Timeout still pending; capture and clear
                                    contToResume = cont
                                    self.locationContinuation = nil
                                    self.pendingAccuracyThresholdMeters = nil
                                    let _ = self.pendingTimeoutTask?.cancel()
                                    self.pendingTimeoutTask = nil
                                    self.isCurrentLocationRequestInProgress = false
                                }
                            }
                            if let cont = contToResume {
                                Task { @MainActor in self.lastError = .timeout }
                                cont.resume(throwing: LocationError.timeout)
                            }
                        }
                    } else {
                        self.pendingTimeoutTask = nil
                    }
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

            var contToResume: CheckedContinuation<Location, Error>? = nil
            continuationLock.withLock {
                if let continuation = self.locationContinuation {
                    // Check accuracy threshold if provided
                    if let threshold = self.pendingAccuracyThresholdMeters {
                        let acc = clLocation.horizontalAccuracy
                        if acc < 0 || acc > threshold {
                            // Not accurate enough yet; keep waiting
                            return
                        }
                    }
                    contToResume = continuation
                    self.locationContinuation = nil
                    self.pendingAccuracyThresholdMeters = nil
                    let _ = self.pendingTimeoutTask?.cancel()
                    self.pendingTimeoutTask = nil
                    self.isCurrentLocationRequestInProgress = false
                }
            }
            if let cont = contToResume {
                cont.resume(returning: newLocation)
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

            var contToResume: CheckedContinuation<Location, Error>? = nil
            continuationLock.withLock {
                if let continuation = self.locationContinuation {
                    contToResume = continuation
                    self.locationContinuation = nil
                    self.pendingAccuracyThresholdMeters = nil
                    let _ = self.pendingTimeoutTask?.cancel()
                    self.pendingTimeoutTask = nil
                    self.isCurrentLocationRequestInProgress = false
                }
            }
            if let cont = contToResume {
                cont.resume(throwing: locationError)
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
