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
        locationViewModel.outputLocation.bind { response in
            switch response {
            case .success:
                self.locationLabel.text = "나의 위치"
                print("location O")
            default:
                self.locationLabel.text = "위치 알 수 없음"
                self.locationAuthDeniedAlert()
                print("location X")
            }
        }
        
        locationViewModel.outputAddress.bind { response in
            switch response {
            case .success(let location):
                self.localityLabel.text = location
            default:
                self.localityLabel.text = "주소 알 수 없음"
            }
        }
        
        locationViewModel.outputWeather.bind { response in
            if let response {
                switch response {
                case .success(let weather):
                    self.setData(response: weather)
                case .fail:
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .lightGray])
                    self.weatherImageView.image = UIImage(systemName: "sun.max.trianglebadge.exclamationmark")
                    self.weatherImageView.preferredSymbolConfiguration = config
                    self.feelsLikeTempLabel.text = "날씨 정보 불러올 수 없음"
                }
            }
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
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
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
            weatherImage(url: url)
        }
        
        tempLabel.text = "\(weather.온도)°"
        feelsLikeTempLabel.text = "체감온도: \(weather.체감온도)°"
        minMaxTempLabel.text = "최고: \(weather.최고온도)°  최저: \(weather.최저온도)°"
        humidityLabel.text = "습도: \(weather.humidity)%"
        
    }
    
    private func locationAuthDeniedAlert() {
        let alert = UIAlertController(title: "위치 접근 불가", message: "위치 접근이 거절되었습니다. 설정에서 위치 접근을 허용해주세요.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func weatherImage(url: URL?) {
        weatherImageView.kf.setImage(
            with: url,
            completionHandler: { result in
                switch result {
                case .success:
                    print("success")
                case .failure:
                    let config = UIImage.SymbolConfiguration(paletteColors: [.lightGray, .red])
                    self.weatherImageView.image = UIImage(systemName: "sun.max.trianglebadge.exclamationmark")
                    self.weatherImageView.preferredSymbolConfiguration = config
                }
            }
        )
    }
    
    
}
