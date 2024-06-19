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
}

struct Icon: Decodable {
    let icon: String
}
