//
//  RTSliderThumbView.swift
//  Routes
//
//  Created by Mac on 23.10.2021.
//

import Foundation
import UIKit

class RTSliderThumbView: UIView {
    
    private struct Border {
        static let width: CGFloat = 2
        static let color = UIColor.RGBA(58, 60, 63, 0.5)
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfigurations()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Methods
    
    func round() {
        layer.cornerRadius = frame.width/2
        layer.masksToBounds = true
    }
    
    func addBorder() {
        borderWidth = Border.width
        borderAlpha = 1
        borderColor = Border.color
    }
    
    // MARK: - Configurations
    
    private func defaultConfigurations() {
        backgroundColor = .white
    }
}
