//
//  CLLocationCoordinate2D+extension.swift
//  Routes
//
//  Created by Mac on 18.09.2021.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func isEqualWith(coordinate: CLLocationCoordinate2D) -> Bool {
        let precise: Double = 0.00001
        let multiplier = 1.0 / precise
        let latitidesEqual: Bool = {
            let firstLat = Int((self.latitude * multiplier).rounded())
            let secondLat = Int((coordinate.latitude * multiplier).rounded())
            return firstLat == secondLat
        }()
        let longitudesEqual: Bool = {
            let firstLon = Int((self.longitude * multiplier).rounded())
            let secondLon = Int((coordinate.longitude * multiplier).rounded())
            return firstLon == secondLon
        }()
        return latitidesEqual && longitudesEqual
    }
}
