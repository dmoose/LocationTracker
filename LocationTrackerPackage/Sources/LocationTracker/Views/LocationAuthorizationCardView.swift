import SwiftUI
import UtilityDesignSystem

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct LocationAuthorizationCardView: View {
    @Environment(LocationTracker.LocationManager.self) private var manager
    @Environment(\.utilityTheme) private var theme

    public init() {}

    public var body: some View {
        UtilityCard(variant: .material) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.sm) {
                    Text("Location").font(.headline)
                    TagBadge(statusLabel, tone: statusTone)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(detailLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if shouldShowRequestButton {
                        Button("Request Permission") {
                            manager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location authorization")
        .accessibilityValue(statusLabel)
    }

    private var statusLabel: String {
        switch manager.authorization {
        case .authorizedAlways:    return "Authorized (Always)"
        case .authorizedWhenInUse: return "Authorized (When In Use)"
        case .authorized:          return "Authorized"
        case .denied:              return "Denied"
        case .restricted:          return "Restricted"
        case .notDetermined:       return "Not Determined"
        }
    }

    private var statusTone: TagTone {
        switch manager.authorization {
        case .authorized, .authorizedAlways, .authorizedWhenInUse: return .success
        case .notDetermined: return .neutral
        case .restricted: return .warning
        case .denied: return .critical
        }
    }

    private var detailLine: String {
        switch manager.authorization {
        case .authorizedAlways:    return "App has background and foreground access."
        case .authorizedWhenInUse: return "App has foreground access."
        case .authorized:          return "App is authorized."
        case .restricted:          return "Access restricted by system policy."
        case .denied:              return "User denied access in Settings."
        case .notDetermined:       return "Permission has not been requested yet."
        }
    }

    private var shouldShowRequestButton: Bool {
        manager.authorization == .notDetermined
    }
}
