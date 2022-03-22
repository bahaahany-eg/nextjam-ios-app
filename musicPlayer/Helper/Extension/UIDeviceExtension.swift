//
//  UIDeviceExtension.swift
//  NextJAM
//
//  Created by apple on 03/11/21.
//

import Foundation
import UIKit
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
