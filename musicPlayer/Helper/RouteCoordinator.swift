//
//  RouteCoordinator.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import Foundation
import UIKit


enum AppStoryboard : String {
    case Main       = "Main"
    case PreLogin   = "PreLogin"
    case Room       = "Room"
    case Player     = "PlayerViewController"
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}


class RouteCoordinator {
    let shared = RouteCoordinator()
    static let Main     = AppStoryboard.Main.instance
    static let PreLogin = AppStoryboard.PreLogin.instance
    static let Room     = AppStoryboard.Room.instance
    static let Player   = AppStoryboard.Player.instance
    
    
    static func NavigateToVC<T>(with identifier: String, Controller: String, Stroyboard: UIStoryboard, presentation: UIModalPresentationStyle,ofType:T,completion: @escaping ((T) -> Void)){
        DispatchQueue.main.async {
            let vc =  Stroyboard.instantiateViewController(withIdentifier: identifier)
            vc.modalPresentationStyle  = presentation
            completion(vc as! T)
        }
    }
}

