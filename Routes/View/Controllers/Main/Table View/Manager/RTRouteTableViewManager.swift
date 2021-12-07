//
//  RTRouteTableViewManager.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

protocol RTRouteTableViewManagerDelegate: AnyObject {
    func onItemSelected(id: String, manager: RTRouteTableViewManager)
}

class RTRouteTableViewManager: NSObject {
    
    struct Data: Equatable {
        struct ItemData: Equatable {
            let id: String
            let title: String
            let rate: Double
            
            static func ==(lItem: ItemData, rItem: ItemData) -> Bool {
                return lItem.id == rItem.id && lItem.title == rItem.title && lItem.rate == rItem.rate
            }
        }
        
        let items: [ItemData]
    }
    
    weak var delegate: RTRouteTableViewManagerDelegate?
    var data: Data? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }
    weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            
            tableView?.register(UITableViewCell.self, forCellReuseIdentifier: kDefaultCellReuseIdentifuer)
            tableView?.tableFooterView = UIView()
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.contentInset = .init(top: 0, left: 0, bottom: SafeAreaBottomOffset, right: 0)
                self?.tableView?.reloadData()
            }
        }
    }
}

// MARK: - Delegate

extension RTRouteTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = self.data,
              data.items.count > indexPath.row else {
            return
        }
        delegate?.onItemSelected(id: data.items[indexPath.row].id, manager: self)
    }
}

// MARK: - Data Source

extension RTRouteTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = self.data,
              data.items.count > indexPath.row else {
            return tableView.dequeueReusableCell(withIdentifier: kDefaultCellReuseIdentifuer, for: indexPath)
        }
        
        let cell = tableView ---> RTTextTableViewCell.self
        cell.viewModel = .init(
            text: .init(
                string: data.items[indexPath.row].title,
                attributes: [
                    .font: UIFont.main(weight: .medium, size: 17),
                    .foregroundColor: UIColor.RGBA(33, 33, 33, 1)
                ]
            ),
            rightText: .init(
                string: "\(data.items[indexPath.row].rate)",
                attributes: [
                    .font: UIFont.main(weight: .medium, size: 17),
                    .foregroundColor: UIColor.RGBA(33, 33, 33, 1)
                ]
            )
        )
        return cell
    }
}
