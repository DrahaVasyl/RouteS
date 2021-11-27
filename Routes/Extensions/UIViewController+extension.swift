//
//  UIViewController+extension.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

extension UIViewController {
    
    func closeCurrentViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        func handleNavigationControllerStack(navigationController: UINavigationController) {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: animated)
            } else if let presentingViewController = navigationController.presentingViewController {
                presentingViewController.dismiss(animated: animated, completion: completion)
            } else {
                self.dismiss(animated: animated, completion: completion)
            }
        }
        
        if let navigationController = self as? UINavigationController {
            handleNavigationControllerStack(navigationController: navigationController)
        } else if let navigationController = self.navigationController {
            handleNavigationControllerStack(navigationController: navigationController)
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
    
}
