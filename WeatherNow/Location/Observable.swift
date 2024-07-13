//
//  Observable.swift
//  WeatherNow
//
//  Created by J Oh on 7/12/24.
//

import Foundation

class Observable<T> {
    
    var closure: ((T) -> Void)?
    
    var value: T {
        didSet {
            print("Value changed")
            closure?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(closure: @escaping (T) -> Void) {
//        closure(value)
        self.closure = closure
    }
    
}
