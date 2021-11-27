//
//  GlobalConstants.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit

let kDefaultCellReuseIdentifuer = "DefaultCellReuseIdentifuer"

var SafeAreaTopOffset: CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0.0
    } else {
        return 0
    }
}

var SafeAreaBottomOffset: CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0.0
    } else {
        return 0
    }
}
