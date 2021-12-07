//
//  RTRouteMapViewModel.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import RxCocoa
import CoreLocation

class RTRouteMapViewModel {
    
    struct Data: Equatable {
        enum MarkerType: Equatable {
            case active
            case inactive
            
            static func ==(lType: MarkerType, rType: MarkerType) -> Bool {
                switch (lType, rType) {
                case (.active, .active),
                     (.inactive, .inactive):
                    return true
                default:
                    return false
                }
            }
        }
        struct Marker: Equatable {
            let id: String
            let lat: Double
            let lon: Double
            let title: String
            let type: MarkerType
            
            static func ==(lMarker: Marker, rMarker: Marker) -> Bool {
                return lMarker.id == rMarker.id &&
                    lMarker.lat == rMarker.lat &&
                    lMarker.lon == rMarker.lon &&
                    lMarker.title == rMarker.title &&
                    lMarker.type == rMarker.type
            }
        }
        
        let markers: [Marker]
    }
    
    // MARK: - Properties
    
    private let route: DBRoute
    let id: String
    let data = BehaviorRelay<Data?>(value: nil)
    var currentPlace: CLPlacemark?
    var routeName: String {
        return route.name
    }
    
    // MARK: - Initialization
    
    init?(id: String) {
        if let route = Database.getRoute(byId: id) {
            self.id = id
            self.route = route
            update()
        } else {
            return nil
        }
    }
    
    // MARK: - Update
    
    private func update() {
        let markers: [Data.Marker] = route.places
            .sorted(by: { left, right in
                return left.sequenceNumber < right.sequenceNumber
            })
            .map({
                return Data.Marker(
                    id: $0.id,
                    lat: $0.lat,
                    lon: $0.lon,
                    title: "\($0.sequenceNumber)",
                    type: .active
                )
            })
        data.accept(.init(markers: markers))
    }
}
