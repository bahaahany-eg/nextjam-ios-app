//
//  SubscriptionVC.swift
//  SubscriptionVC
//
//  Created by apple on 04/10/21.
//

import UIKit
import StoreKit
class SubscriptionVC: UIViewController {

    @IBOutlet weak var appleMusicPermissionBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor =  UIColor(named: "JAM")
    }
    
    @IBAction func showPermissionButtonAction(_ sender: Any) {
        SKCloudServiceController.requestAuthorization { [self] (status) in
            if status == .authorized {
                print("authorised to use Music Kit")
                navigateToCreateProfile()
            } else if status == .denied || status == .notDetermined{
                print("Inside else block of authorization")
                self.checkPermission()
            }
        }
    }
    
    func checkPermission(){
        SKCloudServiceController.requestAuthorization { [self] (Status) in
            switch Status {
            case .notDetermined:
                checkPermission()
            case .restricted:
                checkPermission()
            case .denied:
                checkPermission()
            case .authorized:
                navigateToCreateProfile()
            }
        }
    }
    
    
    func GotoSettings(){
        let alert = Utility().handleUserPermission(title: "\"NextJAM\" would like ot access Apple Music, your music and video activity, adn your media library", message: "App need access to music library to play music. Please allow permission in the applicaiton setting > Media & Apple Music.")
        DispatchQueue.main.async {
            self.present(alert, animated: true) {
                self.navigateToCreateProfile()
            }
        }
    }
    
    
    
    @IBAction func skipBtnAction(_ sender: Any) {
        navigateToCreateProfile()
    }
    func navigateToCreateProfile(){
        RouteCoordinator.NavigateToVC(with: "CreateProfileVC", Controller: "CreateProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: CreateProfileVC()) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension SubscriptionVC{
    func setupUI(){
        self.appleMusicPermissionBtn.layer.cornerRadius = 10
    }
}
