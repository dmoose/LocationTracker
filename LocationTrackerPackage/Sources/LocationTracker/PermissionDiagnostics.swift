import Foundation
import CoreLocation

#if os(iOS)
import UIKit
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension LocationTracker {
    struct PermissionDiagnostics {
        public struct UsageStringsPresence: Sendable {
            public let whenInUse: Bool
            public let alwaysAndWhenInUse: Bool
        }

        /// Check whether the expected Info.plist usage strings are present in the host app.
        public static func usageStringsPresence(in bundle: Bundle = .main) -> UsageStringsPresence {
            let whenInUse = bundle.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
            let always = bundle.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil
            return UsageStringsPresence(whenInUse: whenInUse, alwaysAndWhenInUse: always)
        }

        /// Whether system-wide location services are enabled on this device.
        public static func servicesEnabled() -> Bool {
            CLLocationManager.locationServicesEnabled()
        }

        #if os(iOS)
        /// Open the app's Settings page so the user can modify Location permissions.
        @MainActor
        public static func openAppSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        #endif
    }
}
