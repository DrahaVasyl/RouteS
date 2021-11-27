//
//  UIFont+extension.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import UIKit

extension UIFont {
    class func main(weight: UIFont.Weight = .regular, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
