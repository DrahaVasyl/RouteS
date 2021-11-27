//
//  RTTextTableViewCell.swift
//  Routes
//
//  Created by Mac on 23.09.2021.
//

import Foundation
import UIKit
import SnapKit

class RTTextTableViewCell: UITableViewCell, IdentifiedTableViewCell {
    
    static let identifier = "RTTextTableViewCell"
    
    struct ViewModel {
        let text: NSAttributedString
        let rightText: NSAttributedString?
    }
    
    // MARK: - Properties
    
    var viewModel: ViewModel? {
        didSet {
            titleLabel.attributedText = viewModel?.text
            rightLabel.attributedText = viewModel?.rightText
        }
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        defaultConfigurations()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Configurations
    
    private func configureLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-20)
            make.left.equalTo(titleLabel.snp.right).offset(10)
        }
    }
    
    private func defaultConfigurations() {
        selectionStyle = .none
    }
}
