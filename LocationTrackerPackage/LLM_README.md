# LocationTracker Package

A modern, SwiftUI-friendly wrapper around Core Location for Apple platforms.

## Key Features
- Async one-shot location: `getCurrentLocation(timeout:accuracyThresholdMeters:)`
- Continuous updates with accuracy/distance/background controls
- Significant-change monitoring for low-power scenarios
- In-memory history with optional retention (maxEntries, maxAge)
- Platform-agnostic authorization enum

## Quick Example

```swift
import LocationTracker

@State private var manager = LocationTracker.LocationManager()

Button("Request Permission") {
    manager.requestPermission()
}

Task {
    do {
        let loc = try await manager.getCurrentLocation(timeout: 5)
        print(loc)
    } catch {
        print("Failed:", error)
    }
}
```

## Installation

Add to your Package.swift dependencies:

```swift
.package(url: "[YOUR-REPO-URL]", from: "1.0.0")
```

Then import in your Swift files:

```swift
import LocationTracker
```

## Platform Requirements
- iOS 17+
- macOS 14+
- watchOS 10+
- tvOS 17+
- Swift 5.9+

## Documentation
- **[LLM Agent Guide](LLM_AGENT_GUIDE.md)** - Integration details for AI agents
- **[LLM Reference Card](LLM_REFERENCE_CARD.md)** - Quick reference guide
- **[Package README](README.md)** - Full package documentation
