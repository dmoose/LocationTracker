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
    @State private var distanceFilterString: String = ""
    @State private var allowBackgroundUpdates: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                controls
                status
                Spacer()
            }
            .padding()
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
        }
        .alert(isPresented: .constant(locationManager.lastError != nil), error: locationManager.lastError) {
            // The default "OK" button is sufficient.
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
            Button("Request Permission") {
                locationManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)

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
                // --- Accuracy Setting ---
                VStack(alignment: .leading) {
                    Text("1. Location Accuracy")
                        .font(.subheadline).bold()
                    Picker("Accuracy", selection: $selectedAccuracy) {
                        ForEach(Accuracy.allCases) { accuracy in
                            Text(accuracy.rawValue).tag(accuracy)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    
                    Text("Controls location precision. Higher accuracy uses more battery.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // --- Distance Filter Setting ---
                VStack(alignment: .leading) {
                    Text("2. Update Filter")
                        .font(.subheadline).bold()
                    HStack {
                        Text("Minimum Distance (meters):")
                        TextField("e.g. 100", text: $distanceFilterString)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 100)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        // This tells the system to dismiss the keyboard
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                    }
                    Text("Only get updates after moving this distance. Leave blank for all.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // --- Background Updates Setting ---
                VStack(alignment: .leading) {
                    Text("3. Background Updates")
                        .font(.subheadline).bold()
                    Toggle("Allow Background Updates", isOn: $allowBackgroundUpdates)
                    Text("Requires enabling 'Location updates' in project capabilities.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(platformAppropriateBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(isUpdating)

            Button(isUpdating ? "Stop Continuous Updates" : "Start Continuous Updates") {
                isUpdating.toggle()
                if isUpdating {
                    let distance = Double(distanceFilterString) ?? kCLDistanceFilterNone
                    locationManager.startUpdatingLocation(
                        accuracy: selectedAccuracy.value,
                        distanceFilter: distance,
                        allowsBackgroundUpdates: allowBackgroundUpdates
                    )
                } else {
                    locationManager.stopUpdatingLocation()
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

    private func statusText(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationTracker.LocationManager())
}
