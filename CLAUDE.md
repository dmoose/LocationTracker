# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the package (run from LocationTrackerPackage/)
swift build

# Run tests
swift test

# Run tests with coverage (from LocationTrackerPackage/)
./run-tests.sh

# Clean build artifacts
make clean

# Full cleanup including caches and resolved packages
make distclean
```

The demo app (`LocationTrackerDemo/`) is an Xcode project - open and build in Xcode.

## Project Structure

This is a Swift 6 package for wrapping CoreLocation with a SwiftUI-friendly API.

```
LocationTrackerPackage/     # The Swift package
  Sources/LocationTracker/  # Main source code
  Tests/                    # Unit tests
LocationTrackerDemo/        # Xcode demo app for testing the package
```

## Architecture

**LocationManager** (`LocationManager.swift`) is the main entry point - an `@Observable @MainActor` class that wraps `CLLocationManager`. Key patterns:

- **Observable pattern**: Uses `@Observable` macro for SwiftUI reactivity
- **MainActor isolation**: All public state mutations happen on main thread
- **Continuation-based async**: `getCurrentLocation()` uses `withCheckedThrowingContinuation` with single-flight guard (throws `.alreadyInProgress` if called concurrently)
- **Namespace enum**: All public types nested under `LocationTracker` enum (e.g., `LocationTracker.LocationManager`, `LocationTracker.Location`)

**Key components:**
- `Location.swift` - `Codable, Identifiable, Sendable` value type with `id`, `latitude`, `longitude`, `timestamp`
- `LocationHistoryProvider.swift` - In-memory history with optional `maxEntries` and `maxAge` retention
- `PermissionDiagnostics.swift` - Static utilities: `usageStringsPresence()`, `servicesEnabled()`, `openAppSettings()` (iOS)
- `Geocoder.swift` - `reverse()` for async geocoding, `format()` for placemark display strings
- `Views/` - `LocationAuthorizationCardView`, `LocationStatusCardView` using UtilityDesignSystem

**Platform differences:**
- iOS-only: `pausesLocationUpdatesAutomatically`, `showsBackgroundLocationIndicator`, `openAppSettings()`
- `LocationTracker.Authorization` bridges iOS/macOS authorization status differences

## Dependencies

Local sibling packages (relative paths in Package.swift):
- `UtilityDesignSystemPackage` - UI components and theming
- `DefaultLogger` - Structured logging

## Platform Requirements

- Swift 6.2, iOS 17+, macOS 14+, watchOS 10+
- Info.plist: `NSLocationWhenInUseUsageDescription` required, `NSLocationAlwaysAndWhenInUseUsageDescription` optional
- macOS App Sandbox: Location entitlement required
