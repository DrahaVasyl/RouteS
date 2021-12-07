//
//  RTRoutesViewModel.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import RxSwift
import RxCocoa

class RTRoutesViewModel {
    
    struct Data {
        struct ItemData {
            let id: String
            let title: String
            let rate: Double
        }
        
        let items: [ItemData]
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let firebaseManager = RTRoutesFirebaseManager()
    let data = BehaviorRelay<Data?>(value: nil)
    
    // MARK: - Initialization
    
    init() {
        update()
        subscribe()
    }
    
    // MARK: - Configurations
    
    private func update() {
        let items = Database.getAllRoutes().sorted(by: { l, r in
            return l.createdAt < r.createdAt
        }).map { route in
            return Data.ItemData(id: route.id, title: route.name, rate: route.rate)
        }
        data.accept(.init(items: items))
    }
    
    // MARK: - Subscribe
    
    private func subscribe() {
        firebaseManager.routes.subscribe(onNext: { [weak self] routes in
            guard let value = routes else { return }
            Database.saveRoutes(value, completion: { [weak self] _ in
                self?.update()
            })
        }).disposed(by: disposeBag)
    }
}
