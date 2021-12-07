//
//  Database+Route.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

extension Database {
    class func getRoute(byId id: String, realm: Realm? = Database.realm) -> DBRoute? {
        let route = Database.get(byId: id, type: DBRoute.self, realm: realm)
        return route
    }
    
    class func getOrCreateRoute(byId id: String, realm: Realm? = Database.realm) -> DBRoute? {
        guard let realm = realm else { return nil }
        
        var routeToReturn: DBRoute?
        
        if let route = Database.get(byId: id, type: DBRoute.self, realm: realm) {
            routeToReturn = route
        } else {
            if realm.isInWriteTransaction {
                let route = DBRoute()
                route.id = id
                realm.add(route)
                routeToReturn = route
            } else {
                do {
                    try realm.write {
                        let route = DBRoute()
                        route.id = id
                        realm.add(route)
                        routeToReturn = route
                    }
                    
                }  catch {
                    //                    Crashlytics.crashlytics().record(error: error)
                    return nil
                }
            }
        }
        return routeToReturn
    }
    
    class func getAllRoutes(realm r: Realm? = Database.realm) -> [DBRoute] {
        guard let realm = r else { return [] }
        let routes = [DBRoute](realm.objects(DBRoute.self))
        return routes
    }
    
    class func saveRoutes(
        _ routes: [Route],
        realm: Realm? = Database.realm,
        completion: (Result<Void, Error>) -> Void
    ) {
        Database.safeWrite(writeClosure: {
            let oldRoutes = Database.getAllRoutes().filter { route in
                return !routes.contains(where: {$0.id == route.id})
            }
            realm?.delete(oldRoutes)
            routes.forEach({ route in
                Database.saveRoute(withInfo: route, realm: realm, completion: { _ in })
            })
            return nil
        }, completion: completion)
    }
    
    class func saveRoute(
        withInfo info: Route,
        realm: Realm? = Database.realm,
        completion: (Result<Void, Error>) -> Void
    ) {
        Database.safeWrite(
            realm,
            writeClosure: {
                if let route = Database.getOrCreateRoute(byId: info.id) {
                    route.name = info.name
                    route.createdAt = info.createdAt
                    route.rate = info.rate
                    route.ratedAmount = info.ratedAmount
                    return nil
                } else {
                    return DatabaseError.objectGet(primaryKey: info.id, type: DBPlace.self)
                }
            },
            completion: { result in
                switch result {
                case .failure:
                    completion(result)
                case .success:
                    Database.savePlaces(withInfo: info.places, completion: { result in
                        switch result {
                        case .success:
                            Database.safeWrite(writeClosure: {
                                if let route = Database.getRoute(byId: info.id) {
                                    info.places.forEach { place in
                                        if let place = Database.getPlace(byId: place.id),
                                           !route.places.contains(where: {$0.id == place.id}) {
                                            route.places.append(place)
                                        }
                                    }
                                    return nil
                                } else {
                                    return DatabaseError.objectGet(primaryKey: info.id, type: DBPlace.self)
                                }
                            }, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                }
            }
        )
    }
}
