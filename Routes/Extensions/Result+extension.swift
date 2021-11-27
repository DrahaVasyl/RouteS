//
//  Result+extension.swift
//  Routes
//
//  Created by Mac on 17.09.2021.
//

import Foundation

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}
