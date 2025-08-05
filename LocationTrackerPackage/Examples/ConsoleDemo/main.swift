//
//  main.swift
//  LocationTracker Console Demo
//
//  A simple demonstration of LocationTracker functionality in a command-line application
//

import Foundation
import CoreLocation
import LocationTracker

@main
struct ConsoleDemo {
    static func main() async {
        print("Location Tracker Console Demo")
        print("-----------------------------")

        let locationManager = LocationTracker.LocationManager()

        // 1. Request Permission
        print("\nStep 1: Requesting location permission...")
        await MainActor.run { locationManager.requestPermission() }

        // Wait for the user to respond to the permission dialog
        while locationManager.authorizationStatus == .notDetermined {
            print("Waiting for user to grant permission...")
            try? await Task.sleep(for: .seconds(1))
        }

        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            print("\nPermission was not granted. Status: \(locationManager.authorizationStatus.name)")
            if let error = locationManager.lastError {
                print("Error: \(error.localizedDescription)")
            }
            return
        }

        print("Permission granted!")

        // 2. Get a single, one-shot location
        print("\nStep 2: Getting a single location update...")
        do {
            let location = try await locationManager.getCurrentLocation()
            print("✅ Success! Current location: Lat \(location.latitude), Lon \(location.longitude)")
        } catch {
            print("❌ Error getting single location: \(error.localizedDescription)")
        }

        // 3. Start continuous updates with configuration
        print("\nStep 3: Starting continuous updates for 15 seconds...")
        print("Configuration: Accuracy=100m, Distance Filter=50m")
        locationManager.startUpdatingLocation(accuracy: kCLLocationAccuracyHundredMeters, distanceFilter: 50)

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < 15 {
            if let location = locationManager.currentLocation {
                print("  - Updated location: Lat \(location.latitude), Lon \(location.longitude) at \(location.timestamp.formatted(date: .omitted, time: .standard))")
            } else {
                print("  - Waiting for initial location...")
            }
            try? await Task.sleep(for: .seconds(2))
        }

        // 4. Stop updates and show history
        print("\nStep 4: Stopping updates.")
        locationManager.stopUpdatingLocation()

        print("\nFinal Location History:")
        let history = locationManager.getHistory()
        if history.isEmpty {
            print("History is empty.")
        } else {
            for location in history {
                print("  - [\(location.timestamp.formatted())] Lat: \(location.latitude), Lon: \(location.longitude)")
            }
        }

        // 5. Clear history
        print("\nStep 5: Clearing history.")
        locationManager.clearHistory()
        print("History cleared. Count: \(locationManager.getHistory().count)")

        print("\nDemo finished.")
    }
}

extension CLAuthorizationStatus {
    var name: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default:
            return "Unknown"
        }
    }
}
