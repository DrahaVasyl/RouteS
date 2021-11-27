//
//  RTRoutesViewController.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import UIKit
import RxSwift

class RTRoutesViewController: UIViewController {

    private class Convertor {
        class func convert(_ data: RTRoutesViewModel.Data) -> RTRouteTableViewManager.Data {
            typealias t = RTRouteTableViewManager.Data
            let items = data.items.map({t.ItemData(id: $0.id, title: $0.title, rate: $0.rate)})
            return .init(items: items)
        }
    }
    
    // MARK: - Properties
    
    private let router = RTRoutesRouter()
    private let disposeBag = DisposeBag()
    private let tableViewManager = RTRouteTableViewManager()
    private let viewModel = RTRoutesViewModel()
    // MARK: UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Available routes"
        label.textAlignment = .center
        label.font = UIFont.main(weight: .bold, size: 17)
        return label
    }()
    private let itemsTableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = buildView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        defaultConfigurations()
    }

    // MARK: - Configurations
    
    private func buildView() -> UIView {
        let contentView = UIView()
        // Title
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44)
        }
        // Table View
        contentView.addSubview(itemsTableView)
        itemsTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        return contentView
    }
    
    private func defaultConfigurations() {
        tableViewManager.delegate = self
        tableViewManager.tableView = itemsTableView
        view.backgroundColor = .white
    }
}

// MARK: - RX -

extension RTRoutesViewController {
    private func subscribe() {
        subscribeViewModel()
    }
    
    private func subscribeViewModel() {
        viewModel.data.subscribe(onNext: { [weak self] data in
            guard let value = data,
                  let self = self else {
                return
            }
            self.tableViewManager.data = Convertor.convert(value)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Delegate -

extension RTRoutesViewController: RTRouteTableViewManagerDelegate {
    func onItemSelected(id: String, manager: RTRouteTableViewManager) {
        router.perform(.route(id: id), from: self)
    }
}
