//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Cascade on 2025-06-23.
//

import Foundation
import CoreLocation
import Observation
import DefaultLogger

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

@MainActor
@Observable
public class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let historyProvider: LocationHistoryProvider

    public private(set) var currentLocation: Location?
    public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    public var authorization: LocationTracker.Authorization { .init(authorizationStatus) }
    public private(set) var lastError: LocationError?

    private var locationContinuation: CheckedContinuation<Location, Error>?
    private var pendingAccuracyThresholdMeters: CLLocationAccuracy?
    private var pendingTimeoutTask: Task<Void, Never>?
    private var isCurrentLocationRequestInProgress: Bool = false

    public init(historyProvider: LocationHistoryProvider = .shared) {
        self.historyProvider = historyProvider
        super.init()
        locationManager.delegate = self
        // The initial value is .notDetermained, now fetch the real one.
        self.authorizationStatus = CLLocationManager().authorizationStatus
    }

    public func requestPermission() {
        guard locationManager.authorizationStatus == .notDetermined else { return }
        let logger = Resolver.getLogger()
        Task { await logger.log("Requesting location permission", level: .info, category: "LocationTracker.Permission") }
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation(accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance = kCLDistanceFilterNone, allowsBackgroundUpdates: Bool = false) {
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.allowsBackgroundLocationUpdates = allowsBackgroundUpdates
        let logger = Resolver.getLogger()
        Task { await logger.log("Start updates accuracy=\(accuracy) distanceFilter=\(distanceFilter) bg=\(allowsBackgroundUpdates)", level: .info, category: "LocationTracker.Updates") }
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        let logger = Resolver.getLogger()
        Task { await logger.log("Stop updates", level: .info, category: "LocationTracker.Updates") }
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Power/Behavior Configuration

    /// The type of user activity associated with the location updates.
    /// Helps the system optimize power and accuracy trade-offs.
    /// The type of user activity associated with the location updates. Use this to hint the
    /// system for better power/accuracy trade-offs (e.g., `.fitness`, `.automotiveNavigation`).
    public var activityType: CLActivityType {
        get { locationManager.activityType }
        set {
            locationManager.activityType = newValue
            let logger = Resolver.getLogger()
            Task { await logger.log("Set activityType=\(String(describing: newValue))", level: .debug, category: "LocationTracker.Power") }
        }
    }

    /// Whether the location manager may pause updates to save power.
    /// iOS only.
    #if os(iOS)
    /// Whether the system may pause updates to save power when appropriate. Defaults to `true`.
    public var pausesLocationUpdatesAutomatically: Bool {
        get { locationManager.pausesLocationUpdatesAutomatically }
        set {
            locationManager.pausesLocationUpdatesAutomatically = newValue
            let logger = Resolver.getLogger()
            Task { await logger.log("Set pausesAutomatically=\(newValue)", level: .debug, category: "LocationTracker.Power") }
        }
    }

    /// Whether to show the blue background location indicator when updating in the background.
    /// Whether to show the blue background location indicator when updating in the background.
    /// Displaying this indicator can improve user trust when background updates are enabled.
    public var showsBackgroundLocationIndicator: Bool {
        get { locationManager.showsBackgroundLocationIndicator }
        set {
            locationManager.showsBackgroundLocationIndicator = newValue
            let logger = Resolver.getLogger()
            Task { await logger.log("Set showsBackgroundIndicator=\(newValue)", level: .debug, category: "LocationTracker.Power") }
        }
    }
    #endif

    public func enableBackgroundUpdates(_ allows: Bool) {
        locationManager.allowsBackgroundLocationUpdates = allows
        let logger = Resolver.getLogger()
        Task { await logger.log("Background updates set to \(allows)", level: .info, category: "LocationTracker.Power") }
    }

    /// Start monitoring for significant changes in the user’s location.
    /// This is a low-power alternative to continuous updates.
    /// True while monitoring significant-change updates. Updated on the main actor.
    public private(set) var isMonitoringSignificantChanges: Bool = false

    public func startSignificantChangeUpdates() {
        let logger = Resolver.getLogger()
        Task { await logger.log("Start significant-change updates", level: .info, category: "LocationTracker.Significant") }
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoringSignificantChanges = true
    }

    /// Stop monitoring significant changes.
    public func stopSignificantChangeUpdates() {
        let logger = Resolver.getLogger()
        Task { await logger.log("Stop significant-change updates", level: .info, category: "LocationTracker.Significant") }
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoringSignificantChanges = false
    }

    public func getHistory() -> [Location] {
        historyProvider.getHistory()
    }

    public func clearHistory() {
        historyProvider.clearHistory()
    }

    /// Returns a single current location result.
    /// - Parameters:
    ///   - timeout: Seconds to wait before failing with `LocationError.timeout`. Pass `nil` to wait indefinitely.
    ///   - accuracyThresholdMeters: If provided, the result only resolves when the `horizontalAccuracy` of a fix is less-than-or-equal to this value. Fixes with negative accuracy are ignored. If `nil`, the first fix returned by Core Location is used.
    /// - Throws: `LocationError.authorizationDenied`, `LocationError.authorizationRestricted`, `LocationError.alreadyInProgress`, `LocationError.timeout`, or `LocationError.locationUnavailable`.
    /// - Returns: The resolved `Location`.
    ///
    /// Notes:
    /// - This API is single-flight: concurrent calls fail fast with `.alreadyInProgress`.
    /// - On success or failure, any pending timeout task is cancelled.
    public func getCurrentLocation(timeout: TimeInterval? = nil, accuracyThresholdMeters: CLLocationAccuracy? = nil) async throws -> Location {
        // Read authorization directly from the underlying manager to avoid awaiting main actor
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            let error: LocationError = (status == .restricted) ? .authorizationRestricted : .authorizationDenied
            self.lastError = error
            let logger = Resolver.getLogger()
            Task { await logger.log("getCurrentLocation denied/restricted", level: .warning, category: "LocationTracker.Current") }
            throw error
        }

        // Single-flight guard (atomic check-and-set) BEFORE any suspension
        if isCurrentLocationRequestInProgress || locationContinuation != nil {
            let logger = Resolver.getLogger()
            Task { await logger.log("getCurrentLocation alreadyInProgress", level: .warning, category: "LocationTracker.Current") }
            throw LocationError.alreadyInProgress
        }
        isCurrentLocationRequestInProgress = true

        let logger = Resolver.getLogger()
        Task { await logger.log("getCurrentLocation start timeout=\(timeout ?? -1) threshold=\(accuracyThresholdMeters ?? -1)", level: .debug, category: "LocationTracker.Current") }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.pendingAccuracyThresholdMeters = accuracyThresholdMeters
            // Cancel any previous timeout task (defensive)
            self.pendingTimeoutTask?.cancel()
            if let seconds = timeout, seconds > 0 {
                let nanos = UInt64(seconds * 1_000_000_000)
                self.pendingTimeoutTask = Task {
                    try? await Task.sleep(nanoseconds: nanos)
                    // If we are cancelled, the continuation will be nil.
                    if let cont = self.locationContinuation {
                        self.lastError = .timeout
                        let logger = Resolver.getLogger()
                        await logger.log("getCurrentLocation timeout seconds=\(seconds)", level: .warning, category: "LocationTracker.Current")
                        cont.resume(throwing: LocationError.timeout)
                        self.resetContinuationState()
                    }
                }
            } else {
                self.pendingTimeoutTask = nil
            }
            locationManager.requestLocation()
        }
    }
    
    private func resetContinuationState() {
        locationContinuation = nil
        pendingAccuracyThresholdMeters = nil
        pendingTimeoutTask?.cancel()
        pendingTimeoutTask = nil
        isCurrentLocationRequestInProgress = false
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocation = locations.last else { return }
        let newLocation = Location(from: clLocation)
        let acc = clLocation.horizontalAccuracy
        Task { @MainActor in
            self.currentLocation = newLocation
            self.historyProvider.addLocation(newLocation)
            self.lastError = nil

            if let continuation = self.locationContinuation {
                // Check accuracy threshold if provided
                if let threshold = self.pendingAccuracyThresholdMeters {
                    if acc < 0 || acc > threshold {
                        // Not accurate enough yet; keep waiting (no log to avoid noise)
                        return
                    }
                }
                let logger = Resolver.getLogger()
                Task { await logger.log("getCurrentLocation success lat=\(String(format: "%.5f", newLocation.latitude)) lon=\(String(format: "%.5f", newLocation.longitude)) acc=\(String(format: "%.1f", acc))", level: .info, category: "LocationTracker.Current") }
                continuation.resume(returning: newLocation)
                self.resetContinuationState()
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError: LocationError
        var codeDesc: String = "unknown"
        if let clError = error as? CLError {
            codeDesc = String(describing: clError.code)
        }
        if let clError = error as? CLError, clError.code == .denied {
            locationError = .authorizationDenied
        } else {
            locationError = .locationUnavailable
        }
        Task { @MainActor in
            let logger = Resolver.getLogger()
            await logger.log("CLLocationManager failed code=\(codeDesc) mapped=\(locationError)", level: .warning, category: "LocationTracker.Updates")
            self.lastError = locationError
            if let continuation = self.locationContinuation {
                continuation.resume(throwing: locationError)
                self.resetContinuationState()
            }
        }
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        Task { @MainActor in
            let logger = Resolver.getLogger()
            await logger.log("Authorization changed to \(String(describing: newStatus))", level: .info, category: "LocationTracker.Permission")
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
