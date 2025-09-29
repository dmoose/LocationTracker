# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## High-level Architecture

The `LocationTracker` package provides a modern, SwiftUI-friendly way to track location on Apple platforms. The key components are:

*   **`LocationManager`**: An `@Observable` class that acts as the main entry point to the package. It wraps `CLLocationManager` to provide a simplified API for:
    *   Requesting user permissions.
    *   Starting and stopping location updates.
    *   Getting the current location asynchronously.
    *   Managing authorization status and errors.
*   **`Location`**: A simple, `Codable` and `Identifiable` struct that represents a geographical location, including latitude, longitude, and a timestamp.
*   **`LocationHistoryProvider`**: A class that provides an in-memory store for the user's location history. `LocationManager` uses a shared instance of this provider to log locations.
*   **`LocationTracker`**: A namespace that contains all the package's types and functionality.

The package is designed to be easy to integrate into SwiftUI applications, using the `@State` property wrapper to create and manage an instance of `LocationManager`.

## Commonly Used Commands

### Building

To build the `LocationTracker` package, run the following command from the `LocationTrackerPackage` directory:

```bash
swift build
```

### Testing

The project includes a comprehensive test script that runs unit tests and generates a code coverage report. To run the tests, navigate to the `LocationTrackerPackage` directory and execute:

```bash
./run-tests.sh
```

To run a single test, you can use the `swift test --filter` command. For example, to run the `testExample` test in the `LocationTrackerTests` class, use the following command:

```bash
swift test --filter LocationTrackerTests/testExample
```

### Linting

There is no specific linting command in this project.

### Documentation

The project uses the `swift-docc-plugin` to generate documentation. To build the documentation, run the following command from the `LocationTrackerPackage` directory:

```bash
./build-docs.sh
```

You can then preview the documentation locally by running:

```bash
./build-docs.sh --preview
```

## Development

The repository includes a demo application that showcases the `LocationTracker` package's functionality. To get started:

1.  Open `LocationTrackerDemo/LocationTrackerDemo.xcodeproj` in Xcode.
2.  Build and run the `LocationTrackerDemo` scheme on a simulator or device.

The demo app provides a simple UI for requesting location permissions, starting and stopping location tracking, and viewing the current location and authorization status.

