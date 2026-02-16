# LocationTracker Quick Reference

## Import

```swift
import LocationTracker
```

## Key Types

- `LocationTracker.LocationManager` - `@Observable @MainActor` entry point wrapping CLLocationManager
- `LocationTracker.Location` - `Codable, Identifiable, Sendable` value type with `id: UUID`, `latitude: Double`, `longitude: Double`, `timestamp: Date`
- `LocationTracker.LocationHistoryProvider` - In-memory history with optional `maxEntries` and `maxAge` retention
- `LocationTracker.Authorization` - Platform-agnostic authorization state enum
- `LocationTracker.LocationError` - Error cases for location operations
- `LocationTracker.PermissionDiagnostics` - Static utilities for checking Info.plist config and location services
- `LocationTracker.Geocoder` - Reverse geocoding utilities

## LocationManager Methods

```swift
// Permissions
func requestPermission()

// One-shot location (single-flight: throws .alreadyInProgress if called concurrently)
func getCurrentLocation(timeout: TimeInterval? = nil,
                        accuracyThresholdMeters: CLLocationAccuracy? = nil) async throws -> Location

// Continuous updates
func startUpdatingLocation(accuracy: CLLocationAccuracy,
                           distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
                           allowsBackgroundUpdates: Bool = false)
func stopUpdatingLocation()

// Significant-change updates (low power)
func startSignificantChangeUpdates()
func stopSignificantChangeUpdates()

// History
func getHistory() -> [Location]
func clearHistory()

// Power/behavior
var activityType: CLActivityType { get set }
func enableBackgroundUpdates(_ allows: Bool)
#if os(iOS)
var pausesLocationUpdatesAutomatically: Bool { get set }
var showsBackgroundLocationIndicator: Bool { get set }
#endif
```

## LocationManager Properties

```swift
var currentLocation: Location? { get }
var authorizationStatus: CLAuthorizationStatus { get }
var authorization: LocationTracker.Authorization { get }
var lastError: LocationError? { get }
var isMonitoringSignificantChanges: Bool { get }
```

## PermissionDiagnostics

```swift
// Check if Info.plist has required usage strings
static func usageStringsPresence(in bundle: Bundle = .main) -> UsageStringsPresence
// Returns: UsageStringsPresence with .whenInUse: Bool, .alwaysAndWhenInUse: Bool

// Check if system location services are enabled
static func servicesEnabled() -> Bool

#if os(iOS)
// Open app's Settings page for location permissions
@MainActor static func openAppSettings()
#endif
```

## Geocoder

```swift
// Reverse geocode a Location to CLPlacemark
static func reverse(location: Location, preferredLocale: Locale? = nil) async throws -> CLPlacemark?

// Format placemark as user-friendly string (e.g., "Cupertino, CA, United States")
static func format(placemark: CLPlacemark) -> String
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

- Swift 6.2, iOS 17+, macOS 14+, watchOS 10+
- Info.plist: `NSLocationWhenInUseUsageDescription` (required), `NSLocationAlwaysAndWhenInUseUsageDescription` (optional)
- macOS App Sandbox: Location entitlement
