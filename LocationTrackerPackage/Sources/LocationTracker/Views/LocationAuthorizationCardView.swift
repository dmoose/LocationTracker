import SwiftUI
import UtilityDesignSystem
import DefaultLogger

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

                    // Diagnose missing usage strings
                    let usage = LocationTracker.PermissionDiagnostics.usageStringsPresence()
                    if !usage.whenInUse {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Configuration issue: Missing NSLocationWhenInUseUsageDescription in Info.plist")
                                .font(.caption)
                                .foregroundStyle(.red)
                            #if os(iOS)
                            Button("Open Settings") {
                                let logger = Resolver.getLogger()
                                Task { @MainActor in
                                    await logger.log("Opening Settings due to missing WhenInUse usage string", level: .warning, category: "LocationTracker.Permission")
                                    LocationTracker.PermissionDiagnostics.openAppSettings()
                                }
                            }
                            .buttonStyle(.bordered)
                            #endif
                        }
                    }

                    if shouldShowRequestButton {
                        Button("Request Permission") {
                            let logger = Resolver.getLogger()
                            Task { @MainActor in
                                await logger.log("Request Permission tapped", level: .info, category: "LocationTracker.Permission")
                                manager.requestPermission()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else if deniedOrRestricted {
                        #if os(iOS)
                        Button("Open Settings") {
                            let logger = Resolver.getLogger()
                            Task { @MainActor in
                                await logger.log("Open Settings tapped (denied/restricted)", level: .info, category: "LocationTracker.Permission")
                                LocationTracker.PermissionDiagnostics.openAppSettings()
                            }
                        }
                        .buttonStyle(.bordered)
                        #endif
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

    private var deniedOrRestricted: Bool {
        manager.authorization == .denied || manager.authorization == .restricted
    }
}
