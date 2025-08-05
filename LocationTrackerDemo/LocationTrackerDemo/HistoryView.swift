//
//  HistoryView.swift
//  LocationTrackerDemo
//
//  Created by Cascade on 2025-06-23.
//

import SwiftUI
import LocationTracker

struct HistoryView: View {
    @Environment(LocationTracker.LocationManager.self) private var locationManager
    
    var body: some View {
        List(locationManager.getHistory()) { location in
            VStack(alignment: .leading) {
                Text("Lat: \(location.latitude)")
                Text("Lon: \(location.longitude)")
                Text(location.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Location History")
    }
}

#Preview {
    // Create a dummy manager for the preview
    let previewManager = LocationTracker.LocationManager()
    return HistoryView()
        .environment(previewManager)
}
