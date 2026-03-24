# LocationTracker

A Swift package wrapping CLLocationManager with a clean async API for iOS, macOS, and watchOS.

## Features

- Continuous and significant-change location monitoring
- Single-shot location with timeout and accuracy gating
- Location history with configurable retention (maxEntries, maxAge)
- Reverse geocoding with address formatting
- Activity type, power management, and background indicator controls
- Permission diagnostics and authorization status mapping
- os.Logger integration

## Usage

```swift
import LocationTracker

let tracker = LocationTracker()

// Start continuous updates
try await tracker.startUpdating(
    distanceFilter: 10,
    desiredAccuracy: kCLLocationAccuracyBest
)

// Single-shot location
let location = try await tracker.getCurrentLocation(
    timeout: 10,
    accuracyThresholdMeters: 50
)

// History
let recent = tracker.history.entries(limit: 20)

// Reverse geocode
let address = try await tracker.geocoder.reverseGeocode(location.coordinate)
```

## Requirements

- iOS 17+ / macOS 14+ / watchOS 10+
- Swift 6.0+

## Integration

Add to your `Package.swift`:

```swift
.package(path: "../LocationTracker/LocationTrackerPackage")
```

## License

MIT
