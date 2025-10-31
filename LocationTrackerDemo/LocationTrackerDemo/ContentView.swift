//
//  ContentView.swift
//  LocationTrackerDemo
//
//  Created by Jeff Shumate on 6/23/25.
//

//
//  ContentView.swift
//  LocationTrackerDemo
//  Created by Cascade on 2025-06-23.
//

import SwiftUI
import CoreLocation
import LocationTracker

struct ContentView: View {
    @Environment(LocationTracker.LocationManager.self) private var locationManager
    @State private var isUpdating = false
    private enum Accuracy: String, CaseIterable, Identifiable {
        case best = "Best"
        case tenMeters = "10m"
        case hundredMeters = "100m"
        case kilometer = "1km"
        case threeKilometers = "3km"

        var value: CLLocationAccuracy {
            switch self {
            case .best: return kCLLocationAccuracyBest
            case .tenMeters: return kCLLocationAccuracyNearestTenMeters
            case .hundredMeters: return kCLLocationAccuracyHundredMeters
            case .kilometer: return kCLLocationAccuracyKilometer
            case .threeKilometers: return kCLLocationAccuracyThreeKilometers
            }
        }
        var id: Self { self }
    }

    @State private var selectedAccuracy: Accuracy = .best
    @State private var distanceFilter: Double? = nil
    @State private var allowBackgroundUpdates: Bool = false

    // Phase 2: Power/Behavior
    private enum Activity: String, CaseIterable, Identifiable {
        case other = "Other"
        case fitness = "Fitness"
        case automotive = "Automotive"
        case otherNavigation = "Navigation"
        var id: Self { self }
    }
    private enum UpdateMode: String, CaseIterable, Identifiable {
        case continuous = "Continuous"
        case significant = "Significant"
        var id: Self { self }
    }

    @State private var selectedActivity: Activity = .other
    @State private var mode: UpdateMode = .continuous
#if os(iOS)
    @State private var pausesAutomatically: Bool = true
    @State private var showsBGIndicator: Bool = false
#endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    controls
                    status
                }
                .padding()
            }
            .navigationTitle("Location Tracker")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    historyButton
                }
                ToolbarItem(placement: .topBarLeading) {
                    clearHistoryButton
                }
                #else
                ToolbarItem {
                    clearHistoryButton
                }
                ToolbarItem {
                    historyButton
                }
                #endif
            }
            .alert(isPresented: .constant(locationManager.lastError != nil), error: locationManager.lastError) {
                // The default "OK" button is sufficient.
            }
        }
    }

    private var platformAppropriateBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        // A slightly more visible gray for light/dark mode
        return Color.gray.opacity(0.2)
        #endif
    }

    private var header: some View {
        VStack {
            Text("📍")
                .font(.system(size: 60))
            Text("Location Tracker Demo")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(platformAppropriateBackground)
        .cornerRadius(8)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            permissionButton // A new computed property for the dynamic button

            Button("Get Current Location (One-Shot)") {
                Task {
                    do {
                        let location = try await locationManager.getCurrentLocation()
                        print("One-shot location received: \(location)")
                    } catch {
                        // The error is already published to lastError, so the alert will show.
                        print("Failed to get one-shot location: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)

            Divider()

            // Configuration Section
            VStack(alignment: .leading, spacing: 12) {
                // --- Mode ---
                VStack(alignment: .leading) {
                    Text("1. Mode")
                        .font(.subheadline).bold()
                    Picker("Mode", selection: $mode) {
                        ForEach(UpdateMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // --- Accuracy Setting ---
                VStack(alignment: .leading) {
                    Text("2. Location Accuracy")
                        .font(.subheadline).bold()
                    Picker("Accuracy", selection: $selectedAccuracy) {
                        ForEach(Accuracy.allCases) { accuracy in
                            Text(accuracy.rawValue).tag(accuracy)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .disabled(mode == .significant)
                    
                    Text("Controls location precision. Higher accuracy uses more battery.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // --- Distance Filter Setting ---
                VStack(alignment: .leading) {
                    Text("3. Update Filter")
                        .font(.subheadline).bold()
                    HStack {
                        Text("Minimum Distance (meters):")
                            .fixedSize(horizontal: false, vertical: true)
                        TextField("e.g. 100", value: $distanceFilter, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 100)
                            .disabled(mode == .significant)
#if os(iOS)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
#endif
                    }
                    Text("Only get updates after moving this distance. Leave blank for all.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // --- Background Updates Setting ---
                VStack(alignment: .leading) {
                    Text("4. Background Updates")
                        .font(.subheadline).bold()
                    Toggle("Allow Background Updates", isOn: $allowBackgroundUpdates)
                    Text("Requires enabling 'Location updates' in project capabilities.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // --- Power & Behavior ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("4. Power & Behavior")
                        .font(.subheadline).bold()
                    // Activity type
                    Picker("Activity", selection: $selectedActivity) {
                        ForEach(Activity.allCases) { act in
                            Text(act.rawValue).tag(act)
                        }
                    }
                    .pickerStyle(.segmented)
#if os(iOS)
                    Toggle("Pause Automatically", isOn: $pausesAutomatically)
                    Toggle("Show Background Indicator", isOn: $showsBGIndicator)
#endif
                }
            }
            .padding()
            .background(platformAppropriateBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(isUpdating)
            .onChange(of: selectedActivity) { applyPowerBehavior() }
            .onChange(of: allowBackgroundUpdates) { applyPowerBehavior() }
            .onChange(of: mode) { modeChanged() }
#if os(iOS)
            .onChange(of: pausesAutomatically) { applyPowerBehavior() }
            .onChange(of: showsBGIndicator) { applyPowerBehavior() }
#endif

            Button(isUpdating ? "Stop Continuous Updates" : "Start Continuous Updates") {
                isUpdating.toggle()
                if isUpdating {
                    applyPowerBehavior() // apply before starting
                    startAccordingToMode()
                } else {
                    stopAccordingToMode()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(isUpdating ? .red : .blue)
        }
    }

    private var status: some View {
        VStack {
             HStack {
                Text("Status:")
                    .bold()
                Text(statusText(for: locationManager.authorizationStatus))
                    .font(.system(.body, design: .monospaced))
            }
            if let location = locationManager.currentLocation {
                HStack {
                    Text("Lat: \(String(format: "%.4f", location.latitude))")
                    Text("Lon: \(String(format: "%.4f", location.longitude))")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(platformAppropriateBackground)
        .cornerRadius(8)
    }

    private var historyButton: some View {
        NavigationLink("History") {
            HistoryView()
        }
    }

    private var clearHistoryButton: some View {
        Button("Clear History", systemImage: "trash") {
            locationManager.clearHistory()
        }
    }

    @ViewBuilder
    private var permissionButton: some View {
        let status = locationManager.authorizationStatus
        let isDetermined = status != .notDetermined

        Button(action: { locationManager.requestPermission() }) {
            switch status {
            case .notDetermined:
                Text("Request Permission")
#if os(macOS)
            case .authorized:
                Text("Permission Granted")
#else
            case .authorizedWhenInUse, .authorizedAlways:
                Text("Permission Granted")
#endif
            case .denied:
                Text("Permission Denied")
            case .restricted:
                Text("Permission Restricted")
            default:
                Text("Unknown Status")
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDetermined)
#if os(macOS)
        .tint(status == .authorized ? .green : .accentColor)
#else
        .tint(status == .authorizedWhenInUse || status == .authorizedAlways ? .green : .accentColor)
#endif
}

    private func modeChanged() {
        if isUpdating {
            // Restart with new mode
            stopAccordingToMode()
            startAccordingToMode()
        }
    }

    private func startAccordingToMode() {
        switch mode {
        case .continuous:
            let distance = distanceFilter ?? kCLDistanceFilterNone
            locationManager.startUpdatingLocation(
                accuracy: selectedAccuracy.value,
                distanceFilter: distance,
                allowsBackgroundUpdates: allowBackgroundUpdates
            )
        case .significant:
            locationManager.startSignificantChangeUpdates()
        }
    }

    private func stopAccordingToMode() {
        switch mode {
        case .continuous:
            locationManager.stopUpdatingLocation()
        case .significant:
            locationManager.stopSignificantChangeUpdates()
        }
    }

    private func applyPowerBehavior() {
        // Map UI state -> manager settings
        switch selectedActivity {
        case .other:           locationManager.activityType = .other
        case .fitness:         locationManager.activityType = .fitness
        case .automotive:      locationManager.activityType = .automotiveNavigation
        case .otherNavigation: locationManager.activityType = .otherNavigation
        }
        locationManager.enableBackgroundUpdates(allowBackgroundUpdates)
#if os(iOS)
        locationManager.pausesLocationUpdatesAutomatically = pausesAutomatically
        locationManager.showsBackgroundLocationIndicator = showsBGIndicator
#endif
    }

    private func statusText(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted:    return "Restricted"
        case .denied:        return "Denied"
#if os(macOS)
        case .authorized:    return "Authorized"
#else
        case .authorizedAlways:    return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
#endif
        default:             return "Unknown"
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationTracker.LocationManager())
}
