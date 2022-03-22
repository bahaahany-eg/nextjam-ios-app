//
//  UIViewExtension.swift
//  Pods
//
//  Created by apple on 09/09/21.
//

import Foundation
import UIKit

extension UIView  {
    
    func MakeRound() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2;
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
    }
    
    func viewCornerRoundTopLeftSide(value: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    func viewCornerRoundTopRightSide( value: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    func viewCornerRoundBottomLeftSide(value: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func viewCornerRoundBottomRightSide(value: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    func ViewLeftCornerRadius(value: Int){
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
    }
    
    func ViewRightCornerRadius(value: Int){
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(value)
        self.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
    }
    
}
