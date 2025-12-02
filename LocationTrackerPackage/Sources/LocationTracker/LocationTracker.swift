//
//  LocationTracker.swift
//  location-tracker
//
//  Created for LocationTracker package
//

import Foundation
import CoreLocation

/// A namespace for organizing types and functionality related to LocationTracker.
///
/// The `LocationTracker` namespace provides a centralized location for all
/// components of the LocationTracker package, making imports cleaner and
/// improving code organization.
///
/// ## Overview
///
/// This namespace will contain the core functionality of the LocationTracker package.
/// Implement your package-specific types, protocols, and functions within this namespace.
///
/// ## Usage
///
/// ```swift
/// import location-tracker
///
/// // Use components from the package
/// let instance = LocationTracker.YourType()
/// ```
///
/// ## Topics
///
/// Add documentation sections here based on your package's functionality.
/// Replace this comment with actual documentation as you implement the package.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public enum LocationTracker {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker {
    /// Platform-agnostic authorization state.
    public enum Authorization: Equatable {
        case notDetermined
        case restricted
        case denied
        case authorizedWhenInUse
        case authorizedAlways
        case authorized // macOS unified authorized
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension LocationTracker.Authorization {
    #if os(macOS)
    public init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted:    self = .restricted
        case .denied:        self = .denied
        case .authorized:    self = .authorized
        default:             self = .notDetermined
        }
    }
    #else
    public init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:         self = .notDetermined
        case .restricted:            self = .restricted
        case .denied:                self = .denied
        case .authorizedWhenInUse:   self = .authorizedWhenInUse
        case .authorizedAlways:      self = .authorizedAlways
        default:                     self = .notDetermined
        }
    }
    #endif
}
