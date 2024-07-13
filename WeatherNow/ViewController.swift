//
//  ViewController.swift
//  WeatherNow
//
//  Created by J Oh on 6/19/24.
//

import UIKit
import Kingfisher
import SnapKit

class ViewController: UIViewController {
    
    let locationViewModel = LocationViewModel()
    
    let locationLabel = UILabel()
    let localityLabel = UILabel()
    let weatherImageView = UIImageView()
    let tempLabel = UILabel()
    let feelsLikeTempLabel = UILabel()
    let minMaxTempLabel = UILabel()
    let humidityLabel = UILabel()
    let requestButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHierarchy()
        setLayout()
        setUI()
        bindData()
    }
    
    private func bindData() {
        locationViewModel.outputAddress.bind { address in
            self.localityLabel.text = address
        }
        
        locationViewModel.outputWeather.bind { response in
            if let response {
                self.setData(response: response)
            }
        }
        
        locationViewModel.outputAlert.bind { _ in
            self.locationAuthDeniedAlert()
        }
    }
    
    private func setHierarchy() {
        view.addSubview(locationLabel)
        view.addSubview(localityLabel)
        view.addSubview(weatherImageView)
        view.addSubview(tempLabel)
        view.addSubview(feelsLikeTempLabel)
        view.addSubview(minMaxTempLabel)
        view.addSubview(humidityLabel)
        view.addSubview(requestButton)
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
            make.top.equalTo(feelsLikeTempLabel.snp.bottom).offset(5)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(minMaxTempLabel.snp.bottom).offset(5)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        requestButton.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(350)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(50)
        }
        
    }
    
    private func setUI() {
        view.backgroundColor = .bg
        
        locationLabel.text = "나의 위치"
        locationLabel.font = .boldSystemFont(ofSize: 35)
        locationLabel.textAlignment = .center
        
        localityLabel.font = .boldSystemFont(ofSize: 14)
        localityLabel.textAlignment = .center
        
        weatherImageView.contentMode = .scaleAspectFill
        
        tempLabel.font = .boldSystemFont(ofSize: 50)
        feelsLikeTempLabel.font = .boldSystemFont(ofSize: 17)
        minMaxTempLabel.font = .boldSystemFont(ofSize: 17)
        humidityLabel.font = .boldSystemFont(ofSize: 17)
        
        requestButton.setTitle("날씨 불러오기", for: .normal)
        requestButton.layer.cornerRadius = 10
        requestButton.backgroundColor = .systemBlue
        requestButton.addTarget(self, action: #selector(requestWeather), for: .touchUpInside)
        
    }
    
    @objc private func requestWeather() {
        resetData()
        locationViewModel.inputLocationRequest.value = ()
    }
    
    private func resetData() {
        weatherImageView.image = UIImage()
        tempLabel.text = ""
        feelsLikeTempLabel.text = ""
        minMaxTempLabel.text = ""
        humidityLabel.text = ""
    }
    
    private func setData(response: WeatherResponse) {
        let weather = response.main
        
        if let icon = response.weather.first?.icon {
            let url = URL(string: WeatherAPI.iconUrl + icon + "@2x.png")
            weatherImageView.kf.setImage(with: url)
        }
        
        tempLabel.text = "\(weather.온도)°"
        feelsLikeTempLabel.text = "체감온도: \(weather.체감온도)°"
        minMaxTempLabel.text = "최고: \(weather.최고온도)°  최저: \(weather.최저온도)°"
        humidityLabel.text = "습도: \(weather.humidity)%"
        
    }
    
    private func locationAuthDeniedAlert() {
        let alert = UIAlertController(title: "위치 접근", message: "위치 접근이 거절되었습니다. 설정에서 위치 접근을 허용해주세요.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
