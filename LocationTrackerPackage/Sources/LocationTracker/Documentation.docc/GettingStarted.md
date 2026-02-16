# Getting Started with LocationTracker

Learn how to integrate LocationTracker and start tracking user location in your app.

## Overview

LocationTracker provides a SwiftUI-friendly wrapper around CoreLocation. The main entry point is ``LocationTracker/LocationManager``, an `@Observable` class that handles permissions, location updates, and history tracking.

## Platform Configuration

Before requesting location access, configure your app target:

### iOS

Add these keys to your `Info.plist`:

- `NSLocationWhenInUseUsageDescription` - Required for any location access
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Required if you need "Always" access

You can verify these are configured correctly at runtime:

```swift
let presence = LocationTracker.PermissionDiagnostics.usageStringsPresence()
if !presence.whenInUse {
    print("Missing NSLocationWhenInUseUsageDescription in Info.plist")
}
```

### macOS

If using App Sandbox, enable the Location entitlement in Signing & Capabilities.

## Basic Usage

```swift
import SwiftUI
import LocationTracker

struct ContentView: View {
    @State private var manager = LocationTracker.LocationManager()

    var body: some View {
        VStack {
            if let location = manager.currentLocation {
                Text("(\(location.latitude), \(location.longitude))")
            }

            Button("Request Permission") {
                manager.requestPermission()
            }
        }
    }
}
```

## One-Shot Location

Fetch a single location with optional timeout and accuracy threshold:

```swift
do {
    let location = try await manager.getCurrentLocation(
        timeout: 10,
        accuracyThresholdMeters: 100
    )
    print("Got location: \(location.latitude), \(location.longitude)")
} catch LocationTracker.LocationError.timeout {
    print("Location request timed out")
} catch {
    print("Error: \(error)")
}
```

## Continuous Updates

Start and stop location updates with configurable accuracy:

```swift
// Start updates
manager.startUpdatingLocation(
    accuracy: kCLLocationAccuracyNearestTenMeters,
    distanceFilter: 10,
    allowsBackgroundUpdates: false
)

// Stop when done
manager.stopUpdatingLocation()
```

## Significant Change Monitoring

For low-power location monitoring:

```swift
manager.startSignificantChangeUpdates()
// Later...
manager.stopSignificantChangeUpdates()
```

## Next Steps

- <doc:ReverseGeocoding> - Convert coordinates to addresses
- Review the demo app in `LocationTrackerDemo/` for a complete implementation
