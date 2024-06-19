//
//  ViewController.swift
//  WeatherNow
//
//  Created by J Oh on 6/19/24.
//

import UIKit
import Alamofire
import CoreLocation
import Kingfisher
import SnapKit

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    let locationLabel = UILabel()
    let localityLabel = UILabel()
    let weatherImageView = UIImageView()
    let tempLabel = UILabel()
    let feelsLikeTempLabel = UILabel()
    let minMaxTempLabel = UILabel()
    let humidityLabel = UILabel()
    
    var coordinate = CLLocationCoordinate2D() {
        didSet {
            getCurrentCity()
        }
    }
    
    var currentLocality: String = "" {
        didSet {
            localityLabel.text = currentLocality
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        locationManager.delegate = self
        
        checkDeviceLocationAuthorization()
        getCurrentCity()
        requestWeather()
        
        setNavBar()
        setHierarchy()
        setLayout()
        setUI()
          
        
    }

    private func setNavBar() {
        navigationItem.title = "Weather Now"
        
        let request = UIBarButtonItem(image: .weather, style: .plain, target: self, action: #selector(requestWeather))
        request.tintColor = .black
        navigationItem.rightBarButtonItem = request
    }
    
    private func setHierarchy() {
        view.addSubview(locationLabel)
        view.addSubview(localityLabel)
        view.addSubview(weatherImageView)
        view.addSubview(tempLabel)
        view.addSubview(feelsLikeTempLabel)
        view.addSubview(minMaxTempLabel)
        view.addSubview(humidityLabel)
    }
    
    private func setLayout() {
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        localityLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(5)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.top.equalTo(localityLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(100)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView.snp.bottom).offset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        feelsLikeTempLabel.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        minMaxTempLabel.snp.makeConstraints { make in
            make.top.equalTo(feelsLikeTempLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(minMaxTempLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
         
        
    }
    
    private func setUI() {
        locationLabel.text = "나의 위치"
        locationLabel.font = .boldSystemFont(ofSize: 30)
        locationLabel.textAlignment = .center
        
        localityLabel.font = .boldSystemFont(ofSize: 15)
        localityLabel.textAlignment = .center
        
        weatherImageView.contentMode = .scaleAspectFill
        
        tempLabel.font = .boldSystemFont(ofSize: 40)
        
        feelsLikeTempLabel.font = .boldSystemFont(ofSize: 17)
        
        
        minMaxTempLabel.font = .boldSystemFont(ofSize: 17)
        
        humidityLabel.font = .boldSystemFont(ofSize: 17)
        
        
    }
    
    private func setData(response: WeatherResponse) {
        let weatherMain = response.main
        if let icon = response.weather.first?.icon {
            let url = URL(string: WeatherAPI.iconUrl + icon + "@2x.png")
            weatherImageView.kf.setImage(with: url)
        }
        
        tempLabel.text = "\(weatherMain.temp.oneDigitFormat())°"
        feelsLikeTempLabel.text = "체감온도: \(weatherMain.feels_like.oneDigitFormat())°"
        minMaxTempLabel.text = "최고: \(weatherMain.temp_max.oneDigitFormat())°  최저: \(weatherMain.temp_min.oneDigitFormat())°"
        humidityLabel.text = "습도: \(weatherMain.humidity)%"
    }
    
    @objc private func requestWeather() {
        print(#function)
        
        let url = WeatherAPI.url
        let parameters: Parameters = [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "appid": WeatherAPI.key,
            "units": "metric"
        ]
        AF.request(url, parameters: parameters).responseDecodable(of: WeatherResponse.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                self.setData(response: value)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func getCurrentCity() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let locale = Locale(identifier: "Ko-kr")
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            if let error { print(error) }
            guard let placemark = placemarks?.first else { return }
            
            if let locality = placemark.locality, let subLocality = placemark.subLocality {
                self.currentLocality = locality + " " + subLocality
                print(self.currentLocality)
            }
        }
    }
}

// location auth functions
extension ViewController {
    func checkDeviceLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            checkCurrentLocationAuthorization()
        }
    }
    
    func checkCurrentLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            locationAuthDeniedAlert()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print(status)
        }
    }
    
    func locationAuthDeniedAlert() {
        let alert = UIAlertController(title: "위치 권한", message: "위치 권한이 거절되었습니다.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
}

// location manager delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        if let coordinate = locations.last?.coordinate {
            print(coordinate)
            self.coordinate = coordinate
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(#function)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkDeviceLocationAuthorization()
    }
    
    
}
