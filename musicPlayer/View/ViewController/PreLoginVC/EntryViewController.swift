//
//  EntryViewController.swift
//  NextJAM
//
//  Created by apple on 02/09/21.
//

import UIKit

class EntryViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor =  UIColor(named: "JAM")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    //MARK: - Create Account Button Action
    @IBAction func createAccountAction(_ sender: Any) {
        RouteCoordinator.NavigateToVC(with: "PhoneVerificationVC", Controller: "PhoneVerificationVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: PhoneVerificationVC()) { vc in
            vc.createAccount  = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    //MARK: - Sign In Button Action
    @IBAction func signInAction(_ sender: Any) {
        RouteCoordinator.NavigateToVC(with: "PhoneVerificationVC", Controller: "PhoneVerificationVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: PhoneVerificationVC()) { vc in
            vc.createAccount  = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - UI Setup Extension
extension EntryViewController {
    
    //MARK: - Setup buttons
    func setupButtons(){
        self.createAccountButton.layer.cornerRadius  = self.createAccountButton.frame.height / 2
        self.signInButton.layer.cornerRadius = self.signInButton.frame.height / 2
        self.signInButton.layer.borderWidth = 1
        self.signInButton.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
    }
    
}








