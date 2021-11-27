//
//  UITableView+extension.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

protocol IdentifiedTableViewCell {
    static var identifier: String { get }
}

infix operator -->
infix operator --->

extension UITableView {
    
    static func --> <T: UITableViewCell & IdentifiedTableViewCell>(_ tableView: UITableView, _ type: T.Type) -> T {
        if let cell = tableView.dequeueReusableCell(withIdentifier: type.identifier) as? T {
            return cell
        } else {
            tableView.register(UINib.init(nibName: String.init(describing: type.self), bundle: nil), forCellReuseIdentifier: type.identifier)
            return tableView.dequeueReusableCell(withIdentifier: type.identifier) as! T
        }
    }
    
    static func ---> <T: UITableViewCell & IdentifiedTableViewCell>(_ tableView: UITableView, _ type: T.Type) -> T {
        if let cell = tableView.dequeueReusableCell(withIdentifier: type.identifier) as? T {
            return cell
        } else {
            tableView.register(type.self, forCellReuseIdentifier: type.identifier)
            return tableView.dequeueReusableCell(withIdentifier: type.identifier) as! T
        }
    }
}
