//
//  Database+Place.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

extension Database {
    class func getPlace(byId id: String, realm: Realm? = Database.realm) -> DBPlace? {
        let route = Database.get(byId: id, type: DBPlace.self, realm: realm)
        return route
    }
    
    class func getOrCreatePlace(byId id: String, realm: Realm? = Database.realm) -> DBPlace? {
        guard let realm = realm else { return nil }
        
        var placeToReturn: DBPlace?
        
        if let place = Database.get(byId: id, type: DBPlace.self, realm: realm) {
            placeToReturn = place
        } else {
            if realm.isInWriteTransaction {
                let place = DBPlace()
                place.id = id
                realm.add(place)
                placeToReturn = place
            } else {
                do {
                    try realm.write {
                        let place = DBPlace()
                        place.id = id
                        realm.add(place)
                        placeToReturn = place
                    }
                }  catch {
                    //                    Crashlytics.crashlytics().record(error: error)
                    return nil
                }
            }
        }
        return placeToReturn
    }
    
    class func savePlace(
        withInfo info: Place,
        realm: Realm? = Database.realm,
        completion: (Result<Void, Error>) -> Void
    ) {
        Database.safeWrite(
            realm,
            writeClosure: {
                if let place = Database.getOrCreatePlace(byId: info.id) {
                    place.lat = info.lat
                    place.lon = info.lon
                    place.name = info.name
                    place.placeDescription = info.placeDescription
                    place.sequenceNumber = info.sequenceNumber
                    return nil
                } else {
                    return DatabaseError.objectGet(primaryKey: info.id, type: DBPlace.self)
                }
            },
            completion: completion
        )
    }
    
    class func savePlaces(
        withInfo info: [Place],
        realm: Realm? = Database.realm,
        completion: (Result<Void, Error>) -> Void
    ) {
        Database.safeWrite(
            realm, 
            writeClosure: {
                var failedIds: [String] = []
                var error: Error?
                info.forEach { placeInfo in
                    if let place = Database.getOrCreatePlace(byId: placeInfo.id) {
                        place.lat = placeInfo.lat
                        place.lon = placeInfo.lon
                        place.name = placeInfo.name
                        place.placeDescription = placeInfo.placeDescription
                        place.sequenceNumber = placeInfo.sequenceNumber
                    } else {
                        failedIds.append(placeInfo.id)
                    }
                }
                if !failedIds.isEmpty {
                    if failedIds.count == 1,
                       let id = failedIds.first {
                        error = DatabaseError.objectGet(primaryKey: id, type: DBPlace.self)
                    } else {
                        error = DatabaseError.objectsGet(primaryKeys: failedIds, type: DBPlace.self)
                    }
                }
                return error
            },
            completion: completion
        )
    }
}
