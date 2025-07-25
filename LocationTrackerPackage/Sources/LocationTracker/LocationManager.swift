//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Cascade on 2025-06-23.
//

import Foundation
import CoreLocation
import Combine

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker {

    @Observable
    public class LocationManager: NSObject, CLLocationManagerDelegate {
        private let manager = CLLocationManager()
        private let historyProvider: LocationHistoryProvider

        public var currentLocation: Location?
        public var authorizationStatus: CLAuthorizationStatus

        public init(historyProvider: LocationHistoryProvider = .init()) {
            self.historyProvider = historyProvider
            self.authorizationStatus = manager.authorizationStatus
            super.init()
            manager.delegate = self
        }

        /// Requests location permission from the user.
        /// This will request "When In Use" authorization.
        public func requestPermission() {
            manager.requestWhenInUseAuthorization()
        }

        /// Starts location updates with a given precision.
        /// - Parameter precision: The desired location accuracy.
        public func startUpdating(precision: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters) {
            manager.desiredAccuracy = precision
            manager.startUpdatingLocation()
        }

        /// Stops location updates.
        public func stopUpdating() {
            manager.stopUpdatingLocation()
        }
        
        /// Allows or disallows background location updates.
        /// - Parameter allows: A boolean indicating if background updates should be allowed.
        public func setAllowsBackgroundUpdates(_ allows: Bool) {
            manager.allowsBackgroundLocationUpdates = allows
        }

        /// Retrieves the location history.
        /// - Returns: An array of `Location` objects.
        public func getHistory() -> [Location] {
            return historyProvider.getHistory()
        }

        // MARK: - CLLocationManagerDelegate

        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let clLocation = locations.last else { return }
            let location = Location(from: clLocation)
            self.currentLocation = location
            historyProvider.addLocation(location)
        }

        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            // Handle errors here, e.g., by logging them.
            print("Location manager failed with error: \(error.localizedDescription)")
        }

        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
