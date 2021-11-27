//
//  RTRouteMapRouter.swift
//  Routes
//
//  Created by Mac on 23.09.2021.
//

import Foundation
import UIKit

class RTRouteMapRouter {
    
    enum Segue {
        case placeInfo(id: String, shouldShowActions: Bool)
        case rate(id: String)
        case alert(title: String, message: String?)
    }
    
    func perform(_ segue: Segue, from controller: UIViewController, completion: (() -> Void)? = nil) {
        switch segue {
        case .alert(let title, let message):
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alertController.addAction(.init(title: "Got it", style: .default, handler: { [weak alertController] _ in
                alertController?.dismiss(animated: true, completion: nil)
            }))
            controller.present(alertController, animated: true, completion: completion)
            
        case .placeInfo(let id, let shouldShowActions):
            if let vc = RTPlaceInfoViewController(id: id, shouldShowActions: shouldShowActions) {
                vc.delegate = controller as? RTPlaceInfoViewControllerDelegate
                controller.present(vc, animated: true, completion: completion)
            }
            
        case .rate(let id):
            if let vc = RTRateRouteViewController(id: id) {
                vc.delegate = controller as? RTRateRouteViewControllerDelegate
                controller.present(vc, animated: false, completion: completion)
            }
        }
    }
}

