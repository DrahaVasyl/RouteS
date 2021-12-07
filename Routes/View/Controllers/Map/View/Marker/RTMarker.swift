//
//  RTMarker.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import GoogleMaps
import SnapKit

class RTMarker: GMSMarker {
    
    enum MarkerType {
        case active
        case inactive
        
        var isActive: Bool {
            switch self {
            case .active: return true
            case .inactive: return false
            }
        }
    }
    
    let id: String
    private var label: UILabel!
    private var imageView: UIImageView!
    
    var type: MarkerType = .active {
        didSet {
            switch type {
            case .active:
                imageView.image = Design.activeImage
            case .inactive:
                imageView.image = Design.inactiveImage
            }
        }
    }
    
    init(id: String, labelText: String) {
        self.id = id
        
        super.init()
        
        let size = CGSize(width: 38, height: 38)
        let frame = CGRect(origin: .zero, size: size)
        let iconView = UIView(frame: frame)
        
        imageView = UIImageView(image: Design.activeImage)
        iconView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: iconView.bounds.width, height: 40)))
        label.text = labelText
        label.textAlignment = .center
        label.font = UIFont.main(weight: .medium, size: 15)
        iconView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-2)
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        self.iconView = iconView
    }
    
    func sameTitle(with marker: RTMarker) -> Bool {
        return title == marker.title
    }
    
    func samePosition(with marker: RTMarker) -> Bool {
        return position.isEqualWith(coordinate: marker.position)
    }
    
    static func ==(lMarker: RTMarker, rMarker: RTMarker) -> Bool {
        return lMarker.title == rMarker.title &&
            lMarker.type == rMarker.type &&
            lMarker.position.isEqualWith(coordinate: rMarker.position)
    }
}

extension RTMarker {
    private struct Design {
        static let activeImage = UIImage(named: "location-pin-active")
        static let inactiveImage = UIImage(named: "location-pin-inactive")
    }
}
