# LocationTracker Package: LLM Integration Guide

## Package Overview

A minimal, modern wrapper around Core Location for Apple platforms, designed for SwiftUI. It provides a single observable manager, a simple value type for locations, cross-platform authorization normalization, and utilities for history and reverse geocoding.

- **Platform Requirements**: iOS 17+, macOS 14+, watchOS 10+, tvOS 17+
- **Swift Version**: 5.9+
- **Product Name**: `LocationTracker`

## Core Components

### LocationTracker.LocationManager (@Observable)
- Permissions: `requestPermission()`
- One-shot: `getCurrentLocation(timeout:accuracyThresholdMeters:)`
- Continuous: `startUpdatingLocation(accuracy:distanceFilter:allowsBackgroundUpdates:)`, `stopUpdatingLocation()`
- Significant Change: `startSignificantChangeUpdates()`, `stopSignificantChangeUpdates()`
- Power: `activityType`, `pausesLocationUpdatesAutomatically` (iOS), `showsBackgroundLocationIndicator` (iOS)
- State: `currentLocation`, `authorization`, `lastError`, `isMonitoringSignificantChanges`

### LocationTracker.Location (Codable, Identifiable)
- `latitude`, `longitude`, `timestamp`

### LocationTracker.LocationHistoryProvider
- `addLocation`, `getHistory`, `clearHistory`
- Retention: `maxEntries`, `maxAge`

### LocationTracker.Authorization
- `.notDetermined`, `.restricted`, `.denied`, `.authorizedWhenInUse`, `.authorizedAlways`, `.authorized`

### LocationTracker.Geocoder (optional helper)
- `reverse(location:preferredLocale:)` (async) -> `CLPlacemark?`
- `format(placemark:)` -> `String`

## Usage Examples

```swift
import LocationTracker

@State private var manager = LocationTracker.LocationManager()

// Request permission
manager.requestPermission()

// One-shot with timeout
Task {
    let loc = try? await manager.getCurrentLocation(timeout: 5)
}

// Continuous updates
manager.startUpdatingLocation(accuracy: kCLLocationAccuracyNearestTenMeters, distanceFilter: 10)

// Significant change (low power)
manager.startSignificantChangeUpdates()
```

## Error Handling

```swift
import LocationTracker

do {
    _ = try await manager.getCurrentLocation(timeout: 5)
} catch let e as LocationTracker.LocationError {
    switch e {
    case .authorizationDenied, .authorizationRestricted:
        // Prompt user to adjust settings
        break
    case .timeout:
        // Inform user to try again or check connectivity
        break
    default:
        break
    }
}
```

## Best Practices
- Keep continuous accuracy as low as acceptable for battery life.
- Prefer significant-change mode for background or coarse tracking.
- Use a small timeout for getCurrentLocation in UI flows to avoid hanging spinners.
- Cap history with `maxEntries` and/or `maxAge` to avoid unbounded growth.
