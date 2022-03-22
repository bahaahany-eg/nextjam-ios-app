//
//  Utility.swift
//  NextJAM
//
//  Created by apple on 08/09/21.
//

import Foundation
import UIKit


class Utility {
    
    public func showAlert(hasTextField: Bool,title: String, Msg: String, style: UIAlertController.Style, Actions: [UIAlertAction]) -> UIViewController{
        let alert = UIAlertController(title: title, message: Msg, preferredStyle: style)
        Actions.forEach { action in
            alert.addAction(action)
        }
        if hasTextField {
            alert.addTextField { text in

            }
        }
        return alert
    }
    
    public func isDarkTheme() -> Bool {
        var isdarkTheme : Bool = false
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                isdarkTheme = true
            } else {
                isdarkTheme = false
            }
        }
        return isdarkTheme
    }
    
    func openSettings() {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    /*
     "\"NextJAM\" would like to access Apple Music, your music and video activity, and your media library"
     */
    /*
     "App need access to music library to play music. Please allow permission in the applicaiton setting > Media & Apple Music."
     */
    
    public func handleUserPermission(title:String,message:String)->UIViewController{
        let alert = UIAlertController(title:title ,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: "Allow in settings",
                                      style: UIAlertAction.Style.default){ [self] _ in
            openSettings()
        })
        return alert
    }
    
    func difference(from date:Date) ->String{
        let dateRangeStart = Date()
        let dateRangeEnd = date
        let  isScheduled = dateRangeStart < dateRangeEnd
        let components = Calendar.current.dateComponents([.weekday,.hour,.minute,.second, .month], from: dateRangeStart, to: dateRangeEnd)
               
        var str = ""
        
        if components.month! != 0 {
            str = "\(components.month ?? 0)m"
        }else if components.weekday! != 0 {
            str.append("\(abs(components.weekday ?? 0))d")
        }else if components.hour! != 0{
            str.append("\(abs(components.hour ?? 0))h")
        }else if components.minute! != 0 {
            str.append("\(abs(components.minute ?? 0))m")
        }else if components.second! != 0 {
            str.append("\(abs(components.second ?? 0))s")
        }
        var final = ""
        
        if isScheduled{
            final = "After \(str)"
        }else{
            final = "\(str) ago"
        }
        return final
        
    }
    
}
