# LocationTracker

**LocationTracker** is a modern, lightweight Swift package designed to simplify location tracking in your iOS, macOS, and other Apple platform apps. It provides a clean, reactive, and easy-to-use wrapper around `CoreLocation`.

## Overview

The package's core is the `LocationManager` class, which handles everything from requesting user permissions to delivering location updates. It's built with SwiftUI in mind, using the `@Observable` macro to ensure your UI updates in real-time with minimal effort.

### Perfect For

LocationTracker is ideal for any app that needs to:

*   Fetch the user's current location.
*   Request and monitor location permissions.
*   Receive continuous location updates.
*   Optionally track location in the background.
*   Keep a history of recorded locations.

### Key Features

- **Simple API:** An intuitive and straightforward interface for location management.
- **SwiftUI Integration:** Uses `@Observable` for seamless, real-time UI updates on modern Apple platforms (iOS 17+, macOS 14+).
- **Permission Handling:** Simplifies the process of requesting and checking authorization status.
- **Configurable Precision:** Easily set the desired accuracy for location updates.
- **In-Memory History:** Keeps a simple, in-memory log of received locations.
- **Background Updates:** Supports enabling background location tracking.

## Platform Setup

To use this package, you must configure your app target with the correct permissions for each platform.

### iOS

In your app's `Info.plist` file, you must add entries for the location privacy descriptions. The system will show these strings to the user when requesting permission.

1.  `Privacy - Location When In Use Usage Description`
2.  `Privacy - Location Always and When In Use Usage Description` (if you plan to request "Always" access)

### macOS

If your macOS app uses the App Sandbox, you must enable the "Location" entitlement.

1.  Go to your project's target settings.
2.  Select the **Signing & Capabilities** tab.
3.  If you are using the sandbox, find the **App Sandbox** section and check the box for **Location**.

## Usage

Using LocationTracker is simple. Here's a quick example of how to integrate it into a SwiftUI view.

### 1. Add the Package

Add this Swift package to your project as a local dependency.

### 2. Add Privacy Usage Description

In your app's `Info.plist`, you must add a key explaining why you need location access. Without this, permission requests will fail.

-   **Key:** `Privacy - Location When In Use Usage Description`
-   **Value:** `We need your location to show it on the map.`

### 3. Use in SwiftUI

Create an instance of `LocationManager` in your view and use its properties to drive your UI.

```swift
import SwiftUI
import LocationTracker

struct MyLocationView: View {
    @State private var locationManager = LocationTracker.LocationManager()

    var body: some View {
        VStack(spacing: 15) {
            if let location = locationManager.currentLocation {
                Text("Lat: \(location.latitude), Lon: \(location.longitude)")
            } else {
                Text("Fetching location...")
            }

            Text("Status: \(String(describing: locationManager.authorization))")

            Button("Request Permission") {
                locationManager.requestPermission()
            }

            Button("Start Tracking") {
                locationManager.startUpdatingLocation(
                    accuracy: kCLLocationAccuracyBest,
                    distanceFilter: kCLDistanceFilterNone,
                    allowsBackgroundUpdates: false
                )
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}
```

## Demo Apps

The package includes two demo applications to help you understand how to use LocationTracker:

### 1. Xcode Demo App (Recommended)

A full-featured SwiftUI demo app is included in the adjacent `LocationTrackerDemo` Xcode project.

### 2. Console Demo

A simple command-line demo is also available in the `/Examples/ConsoleDemo` directory.

## Building and Testing

The package requires Swift 5.9+ and supports iOS 17+, macOS 14+, tvOS 17+, and watchOS 10+.

```bash
# Build the package
swift build

# Run tests
swift test
```

## License

This package is available under the MIT license. See the LICENSE file for more info.
