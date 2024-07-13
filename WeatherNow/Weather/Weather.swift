//
//  Weather.swift
//  WeatherNow
//
//  Created by J Oh on 6/19/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let weather: [Icon]
    let main: Weather 
}

struct Weather: Decodable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
    
    var 온도: String {
        temp.oneDigitFormat()
    }
    
    var 체감온도: String {
        feels_like.oneDigitFormat()
    }
    
    var 최저온도: String {
        temp_min.oneDigitFormat()
    }
    
    var 최고온도: String {
        temp_max.oneDigitFormat()
    }
    
    
}

struct Icon: Decodable {
    let icon: String
}

//   tempLabel.text = "\(weather.temp.oneDigitFormat())°"
//   feelsLikeTempLabel.text = "체감온도: \(weather.feels_like.oneDigitFormat())°"
//   minMaxTempLabel.text = "최고: \(weather.temp_max.oneDigitFormat())°  최저: \(weather.temp_min.oneDigitFormat())°"
//   humidityLabel.text = "습도: \(weather.humidity)%"
