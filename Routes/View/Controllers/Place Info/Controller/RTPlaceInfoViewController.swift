//
//  RTPlaceInfoViewController.swift
//  Routes
//
//  Created by Mac on 23.09.2021.
//

import Foundation
import SnapKit
import UIKit
import RxSwift

protocol RTPlaceInfoViewControllerDelegate: AnyObject {
    func onSkipButton(id: String, controller: RTPlaceInfoViewController)
    func onNavigateButton(id: String, controller: RTPlaceInfoViewController)
}

class RTPlaceInfoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: RTPlaceInfoViewModel
    private let shouldShowActions: Bool
    var delegate: RTPlaceInfoViewControllerDelegate?
    // MARK: UI
    private let mainContentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    private let topNavigationContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let topNavigationBackButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon-back-arrow"), for: .normal)
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()
    private let topNavigationtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.main(weight: .bold, size: 17)
        return label
    }()
    private let descriptionContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = UIFont.main(size: 15)
        return tv
    }()
    private let buttonsContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 15
        return sv
    }()
    private let navigateButton: UIButton = {
        let button: UIButton
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = UIColor.systemBlue
            configuration.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
            configuration.attributedTitle = AttributedString("Navigate", attributes: .init([
                .font: UIFont.main(size: 15),
                .foregroundColor: UIColor.white
            ]))
            button = UIButton(configuration: configuration, primaryAction: nil)
        } else {
            button = UIButton()
            button.cornerRadius = 22
            button.backgroundColor = UIColor.RGBA(14, 114, 126, 1)
            button.setAttributedTitle(NSAttributedString(
                string: "Navigate",
                attributes: [
                    .font: UIFont.main(size: 15),
                    .foregroundColor: UIColor.white
                ]),
                                      for: .normal
            )
        }
        
        button.clipsToBounds = true
        
        return button
    }()
    private let skipButton: UIButton = {
        let button: UIButton
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.bordered()
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = UIColor.clear
            configuration.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
            configuration.attributedTitle = AttributedString("Skip", attributes: .init([
                .font: UIFont.main(size: 15),
                .foregroundColor: UIColor.RGBA(33, 33, 33, 1)
            ]))
            button = UIButton(configuration: configuration, primaryAction: nil)
        } else {
            button = UIButton()
            button.cornerRadius = 22
            button.setAttributedTitle(NSAttributedString(string: "Skip", attributes: .init([
                .font: UIFont.main(size: 15),
                .foregroundColor: UIColor.RGBA(33, 33, 33, 1)
            ])), for: .normal)
        }
        
        button.clipsToBounds = true
        
        return button
    }()
    
    // MARK: - Initialization
    
    init?(id: String, shouldShowActions: Bool) {
        if let vm = RTPlaceInfoViewModel(id: id) {
            self.viewModel = vm
            self.shouldShowActions = shouldShowActions
            super.init(nibName: nil, bundle: nil)
        } else {
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = buildView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultConfigurations()
        subscribe()
    }
    
    // MARK: - Configurations
    
    private func buildView() -> UIView {
        let contentView = UIView()
        // Main Stack View
        contentView.addSubview(mainContentStackView)
        mainContentStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom)
        }
        // Top Navigation View
        mainContentStackView.addArrangedSubview(topNavigationContentView)
        topNavigationContentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        // Back Button
        topNavigationContentView.addSubview(topNavigationBackButton)
        topNavigationBackButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(44).priority(.high)
            make.bottom.equalToSuperview()
        }
        // Title
        topNavigationContentView.addSubview(topNavigationtitleLabel)
        topNavigationtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(topNavigationBackButton.snp.right)
            make.right.lessThanOrEqualTo(-64)
            make.top.bottom.equalToSuperview()
        }
        // Description
        mainContentStackView.addArrangedSubview(descriptionContentView)
        descriptionContentView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(contentView.snp.height).priority(.medium)
        }
        // Buttons
        mainContentStackView.addArrangedSubview(buttonsContentView)
        buttonsContentView.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        // Navigate Button
        buttonsStackView.addArrangedSubview(navigateButton)
        // Skip Button
        buttonsStackView.addArrangedSubview(skipButton)
        return contentView
    }
    
    private func defaultConfigurations() {
        view.backgroundColor = .white
        topNavigationBackButton.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(onSkipButton), for: .touchUpInside)
        navigateButton.addTarget(self, action: #selector(onNavigateButton), for: .touchUpInside)
        
        buttonsContentView.isHidden = !shouldShowActions
    }
    
    private func configureUI(withData data: RTPlaceInfoViewModel.Data) {
        topNavigationtitleLabel.text = data.name
        descriptionTextView.text = data.placeDescription
    }
    
    // MARK: - Actions
    
    @objc private func onBackButton() {
        closeCurrentViewController()
    }
    
    @objc private func onSkipButton() {
        delegate?.onSkipButton(id: viewModel.id, controller: self)
    }
    
    @objc private func onNavigateButton() {
        delegate?.onNavigateButton(id: viewModel.id, controller: self)
    }
}

// MARK: - RX -

extension RTPlaceInfoViewController {
    private func subscribe() {
        viewModel.data.subscribe(onNext: { [weak self] data in
            guard let self = self,
                    let value = data else {
                return
            }
            self.configureUI(withData: value)
        }).disposed(by: disposeBag)
    }
}
