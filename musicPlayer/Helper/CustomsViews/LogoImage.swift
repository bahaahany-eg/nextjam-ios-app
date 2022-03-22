//
//  LogoImage.swift
//  NextJAM
//
//  Created by apple on 16/11/21.
//

import Foundation
import UIKit



@IBDesignable
class logoView : UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        self.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
        self.layer.borderWidth = 1
    }
}



