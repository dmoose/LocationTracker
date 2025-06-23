# LocationTracker Demo Project

This directory is intended to contain an Xcode project that demonstrates the LocationTracker Swift package.

## Creating the Demo Project

1. Open Xcode and create a new project:
   - Choose a suitable template (e.g., iOS App, macOS App)
   - Name it "LocationTrackerDemo"
   - Place it in this directory

2. Add the LocationTracker package as a dependency:
   - In Xcode, go to File > Add Packages...
   - Click "Add Local..."
   - Navigate to and select the `LocationTrackerPackage` directory
   - Click "Add Package"

3. Implement demo functionality:
   - Create example views that demonstrate different aspects of the package
   - Include basic usage examples
   - Show error handling and other advanced features

## Suggested Structure

```swift
// ContentView.swift
import SwiftUI
import location-tracker

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Basic Example", destination: BasicExampleView())
                NavigationLink("Error Handling", destination: ErrorHandlingView())
                NavigationLink("Advanced Features", destination: AdvancedFeaturesView())
            }
            .navigationTitle("LocationTracker Demos")
        } detail: {
            Text("Select a demo from the sidebar")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+
