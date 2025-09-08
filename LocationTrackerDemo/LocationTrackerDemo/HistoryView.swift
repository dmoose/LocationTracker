//
//  HistoryView.swift
//  LocationTrackerDemo
//
//  Created by Cascade on 2025-06-23.
//

import SwiftUI
import MapKit
import LocationTracker

struct HistoryView: View {
    @Environment(LocationTracker.LocationManager.self) private var locationManager
    @State private var numberOfPointsToShow = 10
    @State private var mapPosition: MapCameraPosition = .automatic

    private var displayedLocations: [LocationTracker.Location] {
        let history = locationManager.getHistory()
        let count = min(numberOfPointsToShow, history.count)
        return Array(history.suffix(count))
    }

    var body: some View {
        VStack {
            historyMap
            controls
            historyList
        }
        .navigationTitle("Location History")
        .onAppear(perform: updateMapPosition)
        .onChange(of: displayedLocations) { // For stepper changes
            updateMapPosition()
        }
        .onChange(of: locationManager.currentLocation) { // For live location updates
            updateMapPosition()
        }
    }

    @ViewBuilder
    private var historyMap: some View {
        Map(position: $mapPosition) {
            // Trail of previous locations as yellow dots
            if displayedLocations.count > 1 {
                ForEach(displayedLocations.dropLast()) { location in
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Circle()
                            .fill(.yellow)
                            .stroke(.orange, lineWidth: 1)
                            .frame(width: 10, height: 10)
                    }
                }
            }

            // Marker for the most recent location
            if let latestLocation = displayedLocations.last {
                Marker(
                    "Latest",
                    systemImage: "figure.walk.circle.fill",
                    coordinate: CLLocationCoordinate2D(latitude: latestLocation.latitude, longitude: latestLocation.longitude)
                )
                .tint(.blue)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private var controls: some View {
        let historyCount = locationManager.getHistory().count
        return Stepper("Points to show: \(numberOfPointsToShow)", value: $numberOfPointsToShow, in: 1...max(1, historyCount))
            .padding()
            .disabled(historyCount == 0)
    }

    private var historyList: some View {
        // Show history in reverse chronological order (most recent first)
        List(locationManager.getHistory().reversed()) { location in
            VStack(alignment: .leading) {
                Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                Text(location.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func updateMapPosition() {
        let coordinates = displayedLocations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        if let region = MKCoordinateRegion(coordinates: coordinates) {
            mapPosition = .region(region)
        }
    }
}

// Helper extension to calculate a bounding region for a set of coordinates
extension MKCoordinateRegion {
    init?(coordinates: [CLLocationCoordinate2D]) {
        // Handle empty or single-coordinate cases
        guard !coordinates.isEmpty else { return nil }
        if coordinates.count == 1 {
            self.init(center: coordinates.first!, latitudinalMeters: 500, longitudinalMeters: 500)
            return
        }

        var minLat = coordinates.first!.latitude
        var maxLat = minLat
        var minLon = coordinates.first!.longitude
        var maxLon = minLon

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
        self.init(center: center, span: span)
    }
}

#Preview {
    // Create a dummy manager for the preview
    let previewManager = LocationTracker.LocationManager()
    return HistoryView()
        .environment(previewManager)
}
