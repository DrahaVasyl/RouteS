//
//  Realm+extension.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation
import RealmSwift

extension Realm {
    func safeWrite(writeClosure: () -> Swift.Error?, completion: (Result<Void, Swift.Error>) -> Void) {
        
        if self.isInWriteTransaction {
            let error = writeClosure()
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.success)
            }
        } else {
            do {
                var error: Swift.Error? = nil
                try self.write {
                    error = writeClosure()
                }
                if let err = error {
                    completion(.failure(err))
                } else {
                    completion(.success)
                }
            } catch {
                //                Crashlytics.crashlytics().record(error: error)
                
                print("Realm could not write to database: ", error)
                completion(.failure(error))
            }
        }
    }
}
