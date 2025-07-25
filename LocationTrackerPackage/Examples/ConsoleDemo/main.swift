//
//  main.swift
//  LocationTracker Console Demo
//
//  A simple demonstration of LocationTracker functionality in a command-line application
//

import Foundation
import LocationTracker

@main
struct ConsoleDemo {
    private let locationManager = LocationTracker.LocationManager()

    static func main() async {
        print("=== LocationTracker Console Demo ===\n")
        let demo = ConsoleDemo()
        await demo.run()
        print("\nDemo completed!")
    }

    func run() async {
        // 1. Request permission and wait for authorization
        print("1. Requesting location permission...")
        locationManager.requestPermission()
        print("   Please grant permission in the system dialog.")

        while locationManager.authorizationStatus == .notDetermined {
            try? await Task.sleep(for: .seconds(1))
        }

        // 2. Check authorization status
        print("\n2. Checking authorization status...")
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            print("   Permission not granted. Status: \(authorizationStatusString(locationManager.authorizationStatus))")
            return
        }
        print("   Permission granted: \(authorizationStatusString(locationManager.authorizationStatus))")

        // 3. Start location updates
        print("\n3. Starting location updates for 15 seconds...")
        locationManager.startUpdating()

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < 15 {
            if let location = locationManager.currentLocation {
                print("   - Updated Location: Lat \(String(format: "%.4f", location.latitude)), Lon \(String(format: "%.4f", location.longitude))")
            } else {
                print("   - Waiting for initial location...")
            }
            try? await Task.sleep(for: .seconds(2))
        }

        // 4. Stop location updates
        print("\n4. Stopping location updates...")
        locationManager.stopUpdating()

        // 5. Display location history
        print("\n5. Displaying location history...")
        let history = locationManager.getHistory()
        if history.isEmpty {
            print("   - No locations recorded.")
        } else {
            for (index, location) in history.enumerated() {
                print("   - [\(index + 1)] Lat \(String(format: "%.4f", location.latitude)), Lon \(String(format: "%.4f", location.longitude)) at \(location.timestamp)")
            }
        }
    }

    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}
