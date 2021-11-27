//
//  RTRateRouteViewController.swift
//  Routes
//
//  Created by Mac on 23.10.2021.
//

import Foundation
import UIKit

protocol RTRateRouteViewControllerDelegate: AnyObject {
    func onCloseButtonClick(controller: RTRateRouteViewController)
    func onApplyButtonClick(controller: RTRateRouteViewController)
}

class RTRateRouteViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: RTRateRouteViewModel
    private var didAppear = false
    weak var delegate: RTRateRouteViewControllerDelegate?
    // MARK: UI
    private let ratesContentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        return sv
    }()
    private let ratesContentView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .white
        view.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private let closeContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon-cross"), for: .normal)
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()
    private let rateTitleContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let rateTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.main(weight: .bold, size: 17)
        return label
    }()
    private let sliderContentView = UIView()
    private let slider: RTRatingSlider = {
        let slider = RTRatingSlider(frame: .zero)
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.minimumTrackTintColor = UIColor.RGBA(2, 199, 124, 1)
        slider.maximumTrackTintColor = UIColor.RGBA(242, 242, 242, 1)
        return slider
    }()
    private let rateLabelContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.main(size: 17)
        label.textAlignment = .right
        return label
    }()
    private let applyContentView: UIView = {
        let view = UIView()
        return view
    }()
    private let applyButton: UIButton = {
        let button: UIButton
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = UIColor.systemBlue
            configuration.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
            configuration.attributedTitle = AttributedString("Apply", attributes: .init([
                .font: UIFont.main(size: 15),
                .foregroundColor: UIColor.white
            ]))
            button = UIButton(configuration: configuration, primaryAction: nil)
        } else {
            button = UIButton()
            button.cornerRadius = 22
            button.backgroundColor = UIColor.RGBA(14, 114, 126, 1)
            button.setAttributedTitle(NSAttributedString(
                string: "Apply",
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
    
    // MARK: - Initialization
    
    init?(id: String) {
        if let viewModel = RTRateRouteViewModel(id: id) {
            self.viewModel = viewModel
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didAppear {
            let operation = BlockOperation(block: {
                UIWindow.showAnimation(
                    backgroundColor: .clear,
                    named: "74694-confetti",
                    loopMode: .playOnce,
                    completion: { [weak self] in
                        UIWindow.hideAnimation()
                        self?.showRateView()
                    })
            })
            operation.queuePriority = .veryHigh
            OperationQueue.main.addOperation(operation)
        }
        didAppear = true
    }
    
    // MARK: - Configurations
    
    private func buildView() -> UIView {
        let contentView = UIView()
        // Rates Content
        contentView.addSubview(ratesContentView)
        ratesContentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.right.lessThanOrEqualToSuperview()
        }
        // Rates Content Stack View
        ratesContentView.addSubview(ratesContentStackView)
        ratesContentStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
        // Cross Button
        ratesContentStackView.addArrangedSubview(closeContentView)
        closeContentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.equalTo(64)
            make.height.equalTo(44)
            make.bottom.top.left.equalToSuperview()
        }
        // Title
        ratesContentStackView.addArrangedSubview(rateTitleContentView)
        rateTitleContentView.addSubview(rateTitleLabel)
        rateTitleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        // Slider
        ratesContentStackView.addArrangedSubview(sliderContentView)
        sliderContentView.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(15)
        }
        // Label
        ratesContentStackView.addArrangedSubview(rateLabelContentView)
        rateLabelContentView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        // Apply
        ratesContentStackView.addArrangedSubview(applyContentView)
        applyContentView.addSubview(applyButton)
        applyButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        return contentView
    }
    
    private func defaultConfigurations() {
        slider.delegate = self
        
        closeButton.addTarget(self, action: #selector(onCloseButton), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(onApplyButton), for: .touchUpInside)
        rateTitleLabel.text = """
Congrats! You’ve finished route "\(viewModel.name)", how would you rate it?
"""
        
        deactivateApplyButton()
        updateVisibleRatingText(rate: 0)
    }
    
    // MARK: - Actions
    
    @objc private func onCloseButton() {
        delegate?.onCloseButtonClick(controller: self)
    }
    
    @objc private func onApplyButton() {
        viewModel.rate(Int(slider.value))
        delegate?.onCloseButtonClick(controller: self)
    }
    
    // MARK: - Helpers
    
    private func correctValue(from value: Float) -> Int {
        let roundedStepValue = round(value)
        let intValue = Int(roundedStepValue)
        return intValue
    }

    private func showRateView() {
        UIView.animate(withDuration: 0.3) {
            self.ratesContentView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func activateApplyButton() {
        applyButton.isUserInteractionEnabled = true
        if #available(iOS 15.0, *) {
            applyButton.configuration?.baseBackgroundColor = UIColor.systemBlue
        } else {
            applyButton.backgroundColor = UIColor.RGBA(14, 114, 126, 1)
        }
    }
    
    private func deactivateApplyButton() {
        applyButton.isUserInteractionEnabled = false
        if #available(iOS 15.0, *) {
            applyButton.configuration?.baseBackgroundColor = UIColor.systemGray
        } else {
            applyButton.backgroundColor = UIColor.RGBA(174, 177, 182, 1)
        }
    }
    
    private func updateVisibleRatingText(rate: Int) {
        rateLabel.text = "\(rate)/5"
    }
}

extension RTRateRouteViewController: RTRatingSliderDelegate {
    func correctIfNeeded(value: Float, slider: RTRatingSlider) -> Float {
        let roundedStepValue = correctValue(from: value)
        return Float(roundedStepValue)
    }
    
    func valueWasChanged(slider: RTRatingSlider) {
        let value = correctValue(from: slider.value)
        slider.value = Float(value)
        updateVisibleRatingText(rate: value)
        if value > 0 {
            activateApplyButton()
        } else {
            deactivateApplyButton()
        }
    }
}
