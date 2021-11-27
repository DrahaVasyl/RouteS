//
//  DBPlace.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

class DBPlace: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var placeDescription = ""
    @objc dynamic var lat: Double = 0
    @objc dynamic var lon: Double = 0
    @objc dynamic var sequenceNumber: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
