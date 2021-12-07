//
//  RTRatingSlider.swift
//  Routes
//
//  Created by Mac on 23.10.2021.
//

import Foundation
import UIKit

protocol RTRatingSliderDelegate: AnyObject {
    func correctIfNeeded(value: Float, slider: RTRatingSlider) -> Float
    func valueWasChanged(slider: RTRatingSlider)
}

class RTRatingSlider: UISlider {

    private var thumdView: RTSliderThumbView?
    weak var delegate: RTRatingSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let t = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(t)
        addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    deinit {
        removeTarget(self, action: nil, for: .valueChanged)
    }
    
    // supply sufficient height to make new thumb image touchable
    // we are using autolayout so this works
    // otherwise we'd use the bound, above
    override var intrinsicContentSize : CGSize {
        var sz = super.intrinsicContentSize
        sz.height += 30
        return sz
    }
    
    @objc private func sliderValueDidChange() {
        delegate?.valueWasChanged(slider: self)
    }
    
    @objc func tapped(_ g: UIGestureRecognizer) {
        if let s = g.view as? UISlider {
            if s.isHighlighted {
                return // tap on thumb, let slider deal with it
            }
            let pt = g.location(in:s)
            let track = s.trackRect(forBounds: s.bounds)
            if !track.insetBy(dx: 0, dy: -10).contains(pt) {
                return // not on track, forget it
            }
            let percentage = pt.x / s.bounds.size.width
            let delta = Float(percentage) * (s.maximumValue - s.minimumValue)
            let value = s.minimumValue + delta
            let correctValue = delegate?.correctIfNeeded(value: value, slider: self) ?? value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                UIView.animate(withDuration: 0.15) { [weak self] in
                    s.setValue(correctValue, animated: true) { [weak self] in
                        guard let self = self else {return}
                        self.delegate?.valueWasChanged(slider: self)
                    }
                }
            }
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 10
        
        return result
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let resultRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        if thumdView == nil {
            configureThumbView()
        }
        
        thumdView?.center = CGPoint(x: resultRect.midX, y: resultRect.midY)
        
        return resultRect
    }
    
    private func configureThumbView() {
        let view = RTSliderThumbView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 32.0, height: 32.0)))
        view.translatesAutoresizingMaskIntoConstraints = true
        view.isUserInteractionEnabled = false
        view.layer.zPosition = UIWindow.Level.statusBar.rawValue
        view.round()
        view.addBorder()
        addSubview(view)
        thumdView = view
    }
}
