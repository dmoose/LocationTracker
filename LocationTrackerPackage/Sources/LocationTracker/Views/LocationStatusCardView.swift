import SwiftUI
import UtilityDesignSystem

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct LocationStatusCardView: View {
    @Environment(LocationTracker.LocationManager.self) private var manager
    @Environment(\.utilityTheme) private var theme

    public init() {}

    public var body: some View {
        UtilityCard(variant: .material) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.sm) {
                    Text("Status").font(.headline)
                    TagBadge(stateLabel, tone: stateTone)
                    Spacer()
                }

                if let loc = manager.currentLocation {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(spacing: theme.spacing.md) {
                            MetricRow(title: "Lat", value: String(format: "%.4f", loc.latitude), unit: nil, layout: .compact)
                            MetricRow(title: "Lon", value: String(format: "%.4f", loc.longitude), unit: nil, layout: .compact)
                        }
                        Text("Updated: \(loc.timestamp.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No location yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location status")
        .accessibilityValue(accessibilitySummary)
    }

    private var stateLabel: String {
        switch manager.authorization {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return manager.currentLocation == nil ? "Idle" : "Active"
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        }
    }

    private var stateTone: TagTone {
        switch manager.authorization {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return manager.currentLocation == nil ? .neutral : .success
        case .notDetermined: return .neutral
        case .restricted: return .warning
        case .denied: return .critical
        }
    }

    private var accessibilitySummary: String {
        if let loc = manager.currentLocation {
            return "Lat \(String(format: "%.4f", loc.latitude)), Lon \(String(format: "%.4f", loc.longitude))"
        }
        return stateLabel
    }
}
