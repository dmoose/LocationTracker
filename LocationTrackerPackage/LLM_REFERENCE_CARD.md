# LocationTracker Quick Reference

## Import

```swift
import LocationTracker
```

## Key Types

- LocationTracker.LocationManager (Observable)
  - Entry point; wraps CLLocationManager
- LocationTracker.Location (Codable, Identifiable)
  - Captures latitude, longitude, timestamp
- LocationTracker.LocationHistoryProvider
  - In-memory history with optional retention
- LocationTracker.Authorization
  - Platform-agnostic authorization state

## Essential Methods

```swift
// Permissions
LocationTracker.LocationManager.requestPermission()

// One-shot location
func getCurrentLocation(timeout: TimeInterval? = nil,
                       accuracyThresholdMeters: CLLocationAccuracy? = nil) async throws -> LocationTracker.Location

// Continuous updates
func startUpdatingLocation(accuracy: CLLocationAccuracy,
                           distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
                           allowsBackgroundUpdates: Bool = false)
func stopUpdatingLocation()

// Significant-change updates
func startSignificantChangeUpdates()
func stopSignificantChangeUpdates()

// History
func getHistory() -> [LocationTracker.Location]
func clearHistory()

// Power/behavior
var activityType: CLActivityType { get set }
#if os(iOS)
var pausesLocationUpdatesAutomatically: Bool { get set }
var showsBackgroundLocationIndicator: Bool { get set }
#endif
```

## Common Patterns

```swift
// One-shot with timeout
let loc = try await manager.getCurrentLocation(timeout: 5)

// Continuous with distance filter
manager.startUpdatingLocation(accuracy: kCLLocationAccuracyNearestTenMeters,
                              distanceFilter: 10,
                              allowsBackgroundUpdates: false)

// Significant-change (low power)
manager.startSignificantChangeUpdates()
```

## Error Types

```swift
enum LocationTracker.LocationError: Error {
    case authorizationDenied
    case authorizationRestricted
    case locationUnavailable
    case timeout
    case alreadyInProgress
    case unknown
}
```

## Platform Requirements
- iOS 17+, macOS 14+, watchOS 10+, tvOS 17+
- Swift 5.9+
