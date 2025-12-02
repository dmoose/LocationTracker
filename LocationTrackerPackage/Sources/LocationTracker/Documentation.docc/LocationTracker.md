# ``LocationTracker``

A modern, SwiftUI-friendly wrapper around Core Location for Apple platforms.

## Overview

LocationTracker provides a simple, observable API for requesting permissions, fetching a one-shot current location, and subscribing to continuous or significant-change updates. It includes a lightweight in-memory history and cross-platform authorization normalization.

### Key Features

- Simple async getCurrentLocation(timeout:accuracyThresholdMeters:)
- Continuous updates with desired accuracy, distance filter, and power controls
- Significant-change monitoring (low-power alternative)
- In-memory history with optional retention (max entries, max age)
- Platform-agnostic authorization enum

## Getting Started

### Installation

Use Swift Package Manager from Xcode (File > Add Packages…) or add to Package.swift.

### Basic Usage

```swift
import LocationTracker

@State private var manager = LocationTracker.LocationManager()

// Request permission
manager.requestPermission()

// One-shot location (with timeout)
Task {
    do {
        let loc = try await manager.getCurrentLocation(timeout: 5)
        print(loc)
    } catch {
        print("Failed:", error)
    }
}

// Continuous updates
manager.startUpdatingLocation(
    accuracy: kCLLocationAccuracyBest,
    distanceFilter: kCLDistanceFilterNone,
    allowsBackgroundUpdates: false
)
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``LocationTracker``
- ``LocationTracker/LocationManager``
- ``LocationTracker/Location``
- ``LocationTracker/LocationHistoryProvider``

## Requirements

iOS 17.0+, macOS 14.0+, tvOS 17.0+, watchOS 10.0+
Swift 5.9+

## License

LocationTracker is released under the MIT License. See LICENSE for details.
