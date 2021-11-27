//
//  UISlider+extension.swift
//  Routes
//
//  Created by Mac on 23.10.2021.
//

import Foundation
import UIKit

extension UISlider {
    func setValue(_ value: Float, animated: Bool = true, duration: TimeInterval = 1, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration, animations: {
                self.setValue(value, animated: true)
            }, completion: { _ in
                completion?()
            })
        } else {
            setValue(value, animated: false)
            completion?()
        }
    }

}
