//
//  RTRateRouteViewModel.swift
//  Routes
//
//  Created by Mac on 31.10.2021.
//

import Foundation

class RTRateRouteViewModel {
    
    // MARK: - Properties
    
    private let firebaseManager = RTRoutesfirebaseManager()
    private let route: DBRoute
    let id: String
    var name: String {
        return route.name
    }
    
    // MARK: - Initialization
    
    init?(id: String) {
        if let route = Database.getRoute(byId: id) {
            self.route = route
            self.id = id
        } else {
            return nil
        }
    }
    
    func rate(_ rate: Int) {
        firebaseManager.updateRouteRating(id: id, ownRate: rate)
    }
    
}
