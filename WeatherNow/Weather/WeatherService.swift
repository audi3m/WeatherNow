//
//  WeatherService.swift
//  WeatherNow
//
//  Created by J Oh on 6/20/24.
//

import Foundation
import Alamofire
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    
    private init() { }
    
    func requestWeather(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (WeatherResponse) -> Void) {
        let url = WeatherAPI.url
        let parameters: Parameters = [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "units": "metric",
            "appid": WeatherAPI.key
        ]
        
        AF.request(url, parameters: parameters).responseDecodable(of: WeatherResponse.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                completionHandler(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}
