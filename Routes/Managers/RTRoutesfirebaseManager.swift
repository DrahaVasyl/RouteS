//
//  RTRoutesfirebaseManager.swift
//  Routes
//
//  Created by Mac on 27.11.2021.
//

import Foundation
import Firebase
import RxCocoa

class RTRoutesfirebaseManager {
    private class Convertor {
        class func convert(snapshot: FirebaseDatabase.DataSnapshot) -> [Route] {
            var routes = [Route]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let routeData = childSnapshot.value as? [String: Any] {
                    let route = Route(
                        id: childSnapshot.key,
                        name: routeData["name"] as? String ?? "",
                        createdAt: routeData["createdAt"] as? Int ?? 0,
                        rate: routeData["rate"] as? Double ?? 0,
                        ratedAmount: routeData["ratedAmount"] as? Int ?? 0,
                        places: {
                            var places = [Place]()
                            if let firebasePlaces = routeData["places"] as? [String: Any] {
                                firebasePlaces.forEach { key, value in
                                    if let dict = value as? [String: Any] {
                                        places.append(
                                            .init(
                                                id: key,
                                                name: dict["name"] as? String ?? "",
                                                placeDescription: dict["placeDescription"] as? String ?? "",
                                                lat: dict["lat"] as? Double ?? 0,
                                                lon: dict["lon"] as? Double ?? 0,
                                                sequenceNumber: dict["sequenceNumber"] as? Int ?? 0
                                            )
                                        )
                                    }
                                }
                            }
                            return places
                        }()
                    )
                    routes.append(route)
                }
            }
            return routes
        }
    }
    
    private let routesRef: DatabaseReference
    let routes = BehaviorRelay<[Route]?>(value: nil)
    
    init() {
        routesRef = FirebaseDatabase.Database.database(url: "https://routes-326109-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: "routes")
        observe()
    }
    
    func updateRouteRating(id: String, ownRate: Int) {
        if let route = routes.value?.first(where: {$0.id == id}) {
            
            let currentRate = route.rate
            let ratedAmount = route.ratedAmount
            
            let newRatedAmount: Int = ratedAmount + 1
            let newRate: Double = (currentRate * Double(ratedAmount) + Double(ownRate)) / Double((ratedAmount + 1))
            let roundedRate = Double(round(10 * newRate) / 10)
            
            routesRef.child(id).child("rate").setValue(roundedRate)
            routesRef.child(id).child("ratedAmount").setValue(newRatedAmount)
        }
    }
    
    private func observe() {
        routesRef.observe(.value, with: { snapshot in
            let routes = Convertor.convert(snapshot: snapshot)
            self.routes.accept(routes)
        })
    }
}
