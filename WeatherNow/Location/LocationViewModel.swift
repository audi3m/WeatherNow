//
//  LocationViewModel.swift
//  WeatherNow
//
//  Created by J Oh on 7/12/24.
//

import Foundation
import CoreLocation

final class LocationViewModel: NSObject, ObservableObject {
    
    let locationManager = CLLocationManager()
    
    var inputLocationRequest: Observable<Void?> = Observable(nil)
    
    var outputAddress: Observable<String?> = Observable(nil)
    var outputWeather: Observable<WeatherResponse?> = Observable(nil)
    var outputAlert: Observable<Void?> = Observable(nil)
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        inputLocationRequest.bind { _ in
            self.checkDeviceLocationAuthorization()
        }
    }
    
    private func getCurrentCity(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let locale = Locale(identifier: "Ko-kr")
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemark = placemarks?.first else { return }
            
            if let locality = placemark.locality, let subLocality = placemark.subLocality {
                self.outputAddress.value = "\(locality) \(subLocality)"
            } else {
                self.outputAddress.value = "알 수 없음"
            }
        }
    }
    
    private func requestWeather(coordinate: CLLocationCoordinate2D) {
        WeatherService.shared.requestWeather(coordinate: coordinate) { response in
            self.outputWeather.value = response
        }
    }
    
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            getCurrentCity(coordinate: coordinate)
            requestWeather(coordinate: coordinate)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization()
                }
            }
        }
    }
    
    func checkCurrentLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            outputAlert.value = ()
        default:
            print(status)
        }
    }
    
    
}
