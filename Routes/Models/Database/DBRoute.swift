//
//  DBRoute.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

class DBRoute: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var createdAt = 0
    @objc dynamic var rate: Double = 0
    @objc dynamic var ratedAmount: Int = 0
    let places = List<DBPlace>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
