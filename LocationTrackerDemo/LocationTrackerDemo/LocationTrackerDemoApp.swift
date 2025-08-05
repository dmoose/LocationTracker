//
//  LocationTrackerDemoApp.swift
//  LocationTrackerDemo
//
//  Created by Jeff Shumate on 6/23/25.
//

import SwiftUI
import LocationTracker

@main
struct LocationTrackerDemoApp: App {
    @State private var locationManager = LocationTracker.LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationManager)
        }
    }
}
