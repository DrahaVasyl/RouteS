//
//  RTRoutesRouter.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

class RTRoutesRouter {
    
    enum Segue {
        case route(id: String)
    }
    
    func perform(_ segue: Segue, from controller: UIViewController, completion: (() -> Void)? = nil) {
        switch segue {
        case .route(let id):
            if let vc = RTRouteMapViewController(id: id) {
                let navigationVC: UINavigationController
                if let receivedNavigationController = controller as? UINavigationController {
                    navigationVC = receivedNavigationController
                } else {
                    navigationVC = UINavigationController(rootViewController: vc)
                }
                
                navigationVC.setNeedsStatusBarAppearanceUpdate()
                navigationVC.navigationBar.isHidden = true
                navigationVC.modalPresentationStyle = .fullScreen
                
                controller.present(navigationVC, animated: true, completion: completion)
            }
        }
    }
}
