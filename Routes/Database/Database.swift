//
//  Database.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

enum DatabaseError: Error {
    case realmGet
    case realmWrite
    case write(error: Error)
    case realmRead
    case objectGet(primaryKey: String, type: Object.Type)
    case objectsGet(primaryKeys: [String], type: Object.Type)
    case undefinedResponseTypeForSaving
}

class Database: NSObject {
    
    @objc static let shared = Database()
    
    private let schemaVersion: UInt64 = {
        let version: UInt64 = UInt64(Bundle.main.object(forInfoDictionaryKey: "DatabaseSchemeVersion") as! Int)
        return version
    }()
    
    static var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
//            Crashlytics.crashlytics().record(error: error)
            
            do {
                try FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
                return Database.realm
            } catch {
                return nil
            }
        }
    }
    
    static func safeWrite(_ realm: Realm? = Database.realm,
                          writeClosure: () -> Error?,
                          completion: (Result<Void, Error>) -> Void) {
        if let receivedRealm = realm {
            receivedRealm.safeWrite(writeClosure: writeClosure, completion: completion)
        } else {
            completion(.failure(DatabaseError.realmGet))
        }
        
    }
    
    func setup() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock:  { [weak self] migration, oldSchemaVersion in
            guard let `self` = self else {return}
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < self.schemaVersion) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
    }
    
    class func removeAll(_ completion: (Result<Void, Error>) -> Void) {
        guard let realm = Database.realm else {
            completion(.failure(DatabaseError.realmGet))
            return
        }
        
        Database.safeWrite(realm, writeClosure: {
            realm.deleteAll()
            return nil
        }, completion: { (error) in
            completion(error)
        })
    }
    
    class func get<T>(byId id: String, type: T.Type, realm: Realm? = Database.realm) -> T? where T: Object {
        guard let realm = realm else { return nil }
        let object = realm.object(ofType: type, forPrimaryKey: id)
        return object
    }
}
