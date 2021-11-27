//
//  UIWindow+extension.swift
//  Routes
//
//  Created by Mac on 23.09.2021.
//

import Foundation
import UIKit
import Lottie
import SnapKit

fileprivate struct AnimationConstants {
    static let animationViewViewControllerTag = 9999
    static let animationViewWindowTag = 9998
    static let animationViewViewTag = 9997
}

extension UIWindow {
    class func showAnimation(
        tapHandler: (() -> Void)? = nil,
        backgroundColor: UIColor = UIColor.RGBA(0, 0, 0, 0.5),
        named: String,
        loopMode: LottieLoopMode = .loop,
        completion: (() -> Void)? = nil
    ) {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            delegate.window?.showAnimation(
                tapHandler: tapHandler,
                backgroundColor: backgroundColor,
                named: named,
                loopMode: loopMode,
                completion: completion
            )
        }
    }
    
    class func hideAnimation() {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            delegate.window?.hideAnimation()
        }
    }
    
    private func showAnimation(
        tapHandler: (() -> Void)? = nil,
        backgroundColor: UIColor = UIColor.RGBA(0, 0, 0, 0.5),
        named: String,
        loopMode: LottieLoopMode = .loop,
        completion: (() -> Void)? = nil
    ) {
        guard self.viewWithTag(AnimationConstants.animationViewWindowTag) == nil else {return}
        
        if let animationPath: String = {
            let type = "json"
            let resource = named
            return Bundle.main.path(forResource: resource, ofType: type)
        }() {
            let animation = Animation.filepath(animationPath)
            
            let animationView = AnimationView(animation: animation)
            
            animationView.tag = AnimationConstants.animationViewWindowTag
            
            animationView.backgroundColor = backgroundColor
            animationView.loopMode = loopMode
            
            animationView.play(completion: { _ in
                completion?()
            })
            
            if let handler = tapHandler {
                animationView.addTapGestureRecognizer(action: handler)
            }
            addSubview(animationView)
            animationView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func hideAnimation() {
        guard let animationView = self.viewWithTag(AnimationConstants.animationViewWindowTag) else {return}
        animationView.removeFromSuperview()
    }
}
