//
//  Double+Ex.swift
//  WeatherNow
//
//  Created by J Oh on 6/20/24.
//

import Foundation

extension Double {
    func oneDigitFormat() -> String {
        String(format: "%.1f", self)
    }
}
