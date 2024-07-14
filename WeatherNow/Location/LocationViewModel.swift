//
//  LocationViewModel.swift
//  WeatherNow
//
//  Created by J Oh on 7/12/24.
//

import Foundation
import CoreLocation

enum LocationRequest {
    case success
    case fail
}

enum AddressRequest {
    case success(location: String)
    case fail
}

enum WeatherRequest {
    case success(weather: WeatherResponse)
    case fail
}

final class LocationViewModel: NSObject, ObservableObject {
    
    let locationManager = CLLocationManager()
    
    var inputLocationRequest: Observable<Void?> = Observable(nil)
    
    var outputLocation: Observable<LocationRequest?> = Observable(nil)
    var outputAddress: Observable<AddressRequest?> = Observable(nil)
    var outputWeather: Observable<WeatherRequest?> = Observable(nil)
    
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
                self.outputAddress.value = .success(location: "\(locality) \(subLocality)")
            } else {
                self.outputAddress.value = .fail
            }
        }
    }
    
    private func requestWeather(coordinate: CLLocationCoordinate2D) {
        WeatherService.shared.requestWeather(coordinate: coordinate) { response, error  in
            guard error == nil else {
                self.outputWeather.value = .fail
                return
            }
            
            if let response {
                self.outputWeather.value = .success(weather: response)
            }
            
        }
    }
    
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            outputLocation.value = .success
            getCurrentCity(coordinate: coordinate)
            requestWeather(coordinate: coordinate)
        } else {
            outputLocation.value = .fail
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
        default:
            outputLocation.value = .fail
        }
    }
    
    
}
