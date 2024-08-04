//
//  LocationManager.swift
//  Location
//
//  Created by jht2 on 4/6/22.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var region:MKCoordinateRegion
    @Published var delta: Double
    var regionInited = false
    
    override init() {
        print("LocationManager init")
        delta = 0.001
        region = MKCoordinateRegion()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestWhenInUseAuthorization()
        // locationManager.startUpdatingLocation()
    }
    
    func requestUse() {
        print("LocationManager requestUse")
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var userLatitude: String {
        return "\(lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(lastLocation?.coordinate.longitude ?? 0)"
    }
    
    var centerLatitude: String {
        return String(format: "%+.6f", region.center.latitude)
        // return "\(region.center.latitude)"
    }
    
    var centerLongitude: String {
        return String(format: "%+.6f", region.center.longitude)
        // return "\(region.center.longitude)"
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print("locationManager didChangeAuthorization", statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        // let delta = 0.005
        if !regionInited {
            regionInited = true
            centerUserLocation()
        }
//        print("locationManager didUpdateLocations", location)
    }
    
    func centerUserLocation() {
        let lat = lastLocation?.coordinate.latitude ?? 0
        let long = lastLocation?.coordinate.longitude ?? 0
        let loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
        region = MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
    }
}
