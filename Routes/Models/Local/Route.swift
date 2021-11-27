//
//  Route.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation

struct Route {
    let id: String
    let name: String
    let createdAt: Int
    let rate: Double
    let ratedAmount: Int
    let places: [Place]
}
