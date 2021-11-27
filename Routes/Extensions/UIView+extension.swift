//
//  UIView+extension.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "tapGestureRecognizer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self,
                                         &AssociatedObjectKeys.tapGestureRecognizer,
                                         newValue,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance
                = objc_getAssociatedObject(self,
                                           &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(cancelsTouchesInView: Bool = false, action: @escaping (() -> Void)) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the view, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}

// MARK: - @IBInspectable

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderAlpha: CGFloat {
        get {
            if let alpha = layer.borderColor?.alpha {
                return alpha
            } else {
                return 0.0
            }
        }
        set {
            if let color = layer.borderColor {
                let uiColor = UIColor(cgColor: color).withAlphaComponent(newValue)
                layer.borderColor = uiColor.cgColor
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            if let cgBorder = layer.borderColor {
                return UIColor(cgColor: cgBorder)
            } else {
                return UIColor.clear
            }
        }
        set {
            let color: CGColor
            if let alpha = layer.borderColor?.alpha {
                color = newValue.withAlphaComponent(alpha).cgColor
            } else {
                color = newValue.cgColor
            }
            layer.borderColor = color
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
}
