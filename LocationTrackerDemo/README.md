# LocationTracker Demo

This Xcode project demonstrates the features of the `LocationTracker` Swift package.

## Features

The demo app showcases the following functionality:

- **Requesting Permissions:** A button to trigger the OS-level location permission prompt.
- **Single Location Update:** Get the user's current location once.
- **Continuous Updates:** Start and stop a stream of location updates.
- **Configuration:**
    - **Accuracy:** Choose from different levels of location accuracy (e.g., Best, Ten Meters).
    - **Distance Filter:** Set a minimum distance (in meters) the device must move before a new update is delivered.
- **Location History:**
    - View a list of all recorded locations from the current session.
    - Display recent locations as annotations on an interactive map.
    - Use a stepper to control how many recent points are shown on the map.
- **Background Updates:** A toggle to enable location tracking while the app is in the background (requires a one-time project configuration).

## Setup for Background Updates

To test the background location updates feature, you must enable the capability in the Xcode project:

1. In the Xcode Project Navigator, select the **`LocationTrackerDemo`** project file.
2. Select the **`LocationTrackerDemo`** target.
3. Go to the **"Signing & Capabilities"** tab.
4. Click the **"+ Capability"** button.
5. Find and double-click **"Background Modes"** from the list that appears.
6. In the new "Background Modes" section, check the box for **"Location updates"**.

Once enabled, you can use the "Allow Background Updates" toggle in the app.

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+
