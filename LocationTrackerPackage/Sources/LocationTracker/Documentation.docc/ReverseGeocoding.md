# Reverse Geocoding

Learn how to turn coordinates into a human‑readable place name using the optional helper.

## Overview

`LocationTracker.Geocoder` provides a tiny convenience wrapper over `CLGeocoder` to reverse geocode a `Location` into a `CLPlacemark`, and a simple formatter to display it.

## Example

```swift
import LocationTracker

@State private var manager = LocationTracker.LocationManager()
@State private var place: String = ""

Button("Reverse Geocode Current") {
    Task {
        if let loc = manager.currentLocation {
            if let placemark = try await LocationTracker.Geocoder.reverse(location: loc) {
                place = LocationTracker.Geocoder.format(placemark: placemark)
            } else {
                place = "No placemark found"
            }
        }
    }
}
```

## Notes

- Reverse geocoding requires network access and may be rate‑limited by the system.
- Prefer caching results if you call it frequently.

