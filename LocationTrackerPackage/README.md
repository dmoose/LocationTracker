# LocationTracker

**LocationTracker** is a lightweight Swift package designed to a Swift package for locationtracker. It provides an elegant abstraction layer over Swift's concurrency system, making it effortless to handle states, errors, and results while maintaining clean, reactive code.

## Overview

At its core, the package offers a simple yet powerful pattern for managing tasks through the `ObservableSingleTask` class. This class transparently handles the entire lifecycle of operations—from initiation and state tracking to error handling and cancellation—all while seamlessly integrating with SwiftUI through the modern `@Observable` macro.

### Perfect For

LocationTracker is particularly valuable for iOS and macOS applications that need to:

* Perform operations with proper loading indicators and error handling
* Execute background processing tasks with cancellation support
* Maintain responsive UIs during long-running operations
* Implement clean architecture with clear separation between UI and logic
* Handle complex error scenarios with custom error mapping

### Key Features

- **State Management:** Monitor task progress, results, and errors using reactive properties
- **Task Cancellation:** Cancel running tasks to free up resources when no longer needed
- **Customizable Error Handling:** Define custom error-handling logic tailored to your application
- **Seamless SwiftUI Integration:** Uses the `@Observable` macro for real-time UI updates on iOS 17+ and macOS 14+
- **`LocationTracker.ObservableSingleTask`:** A view model for managing a single cancellable task

## Documentation

This package uses GitHub Actions to automatically generate and publish documentation to GitHub Pages.

## Demo Apps

The package includes two demo applications to help you understand how to use LocationTracker:

### 1. Xcode Demo App (Recommended)

A full-featured SwiftUI demo app is included in the adjacent `LocationTrackerDemo` Xcode project.

### 2. Console Demo

A simple command-line demo is also available in the `/Examples/ConsoleDemo` directory.

## Building and Testing

The package requires Swift 5.9+ and supports iOS 17+, macOS 14+, tvOS 17+, and watchOS 10+.

```bash
# Build the package
swift build

# Run tests
swift test
```

## License

This package is available under the MIT license. See the LICENSE file for more info.
