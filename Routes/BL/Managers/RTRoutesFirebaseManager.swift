//
//  RTRoutesFirebaseManager.swift
//  Routes
//
//  Created by Mac on 27.11.2021.
//

import Foundation
import Firebase
import RxCocoa

class RTRoutesFirebaseManager {
    private class Convertor {
        class func convert(snapshot: FirebaseDatabase.DataSnapshot) -> [Route] {
            var routes = [Route]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let routeData = childSnapshot.value as? [String: Any],
                   let routeName = routeData["name"] as? String,
                   let routeCreatedAt = routeData["createdAt"] as? Int {
                    let route = Route(
                        id: childSnapshot.key,
                        name: routeName,
                        createdAt: routeCreatedAt,
                        rate: routeData["rate"] as? Double ?? 0,
                        ratedAmount: routeData["ratedAmount"] as? Int ?? 0,
                        places: {
                            var places = [Place]()
                            if let firebasePlaces = routeData["places"] as? [String: Any] {
                                firebasePlaces.forEach { key, value in
                                    if let dict = value as? [String: Any],
                                       let placeName = dict["name"] as? String,
                                       let placeDescription = dict["placeDescription"] as? String,
                                       let placeLat = dict["lat"] as? Double,
                                       let placeLon = dict["lon"] as? Double,
                                       let placeSequence = dict["sequenceNumber"] as? Int {
                                        places.append(
                                            .init(
                                                id: key,
                                                name: placeName,
                                                placeDescription: placeDescription,
                                                lat: placeLat,
                                                lon: placeLon,
                                                sequenceNumber: placeSequence
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
        routesRef = FirebaseDatabase.Database.database(url: "https://routes-326109-default-rtdb.europe-west1.firebasedatabase.app").reference()
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
        routesRef.observe(.value, with: { [weak self] snapshot in
            let routes = Convertor.convert(snapshot: snapshot)
            self?.routes.accept(routes)
        })
    }
}
