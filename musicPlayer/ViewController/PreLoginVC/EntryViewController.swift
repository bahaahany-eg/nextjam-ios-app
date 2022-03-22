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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    //MARK: - Create Account Button Action
    @IBAction func createAccountAction(_ sender: Any) {
        guard let viewController = RouteCoordinator.NavigateToVC(with: "PhoneVerificationVC", Controller: "PhoneVerificationVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? PhoneVerificationVC else { return }
        viewController.createAccount  = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    //MARK: - Sign In Button Action
    @IBAction func signInAction(_ sender: Any) {
        guard let viewController = RouteCoordinator.NavigateToVC(with: "PhoneVerificationVC", Controller: "PhoneVerificationVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? PhoneVerificationVC else { return }
        viewController.createAccount  = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
//MARK: - UI Setup Extension
extension EntryViewController {
    
    func setupButtons(){
        self.createAccountButton.layer.cornerRadius  = self.createAccountButton.frame.height / 2
        self.signInButton.layer.cornerRadius = self.signInButton.frame.height / 2
        self.signInButton.layer.borderWidth = 1
        self.signInButton.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
    }
    
    func makeLogo(){
        self.logoImage.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
        self.logoImage.layer.borderWidth = 5
        self.logoImage.layer.cornerRadius = self.logoImage.frame.height / 2
    }
    
}








