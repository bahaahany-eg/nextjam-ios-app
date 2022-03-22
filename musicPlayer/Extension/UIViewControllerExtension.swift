//
//  UIViewControllerExtension.swift
//  NextJAM
//
//  Created by apple on 10/09/21.
//

import Foundation
import UIKit


extension UIViewController {
    
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
    
}
