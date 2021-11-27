//
//  RTPlaceInfoViewModel.swift
//  Routes
//
//  Created by Mac on 23.10.2021.
//

import Foundation
import RxCocoa

class RTPlaceInfoViewModel {
    
    struct Data {
        let name: String
        let placeDescription: String
    }
    
    // MARK: - Properties
    
    private let place: DBPlace
    let id: String
    let data = BehaviorRelay<Data?>(value: nil)
    
    // MARK: - Initialization
    
    init?(id: String) {
        if let place = Database.getPlace(byId: id) {
            self.place = place
            self.id = id
            
            updateData()
        } else {
            return nil
        }
    }
    
    // MARK: - Update
    
    private func updateData() {
        let info = Data(name: place.name, placeDescription: place.placeDescription)
        self.data.accept(info)
    }
}
