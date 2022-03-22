//
//  CreateProfileViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
class CreateProfileVC: UIViewController, GIDSignInDelegate {
   
    @IBOutlet weak var createManuallyBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    //MARK: - Fetch profile from Google
    @IBAction func googleLoginAction(_ sender: Any) {
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    // MARK: - Parse User Details from the Goole Response
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else { return }
        guard let username = user.profile.givenName else { return }
        guard let displayname = user.profile.name else { return }
        guard let imageurl = user.profile.imageURL(withDimension: 512) else { return }
        Constants.staticString.USER_DEFAULTS.setValue( username, forKey: Constants.UserDetails.UserName)
        Constants.staticString.USER_DEFAULTS.setValue( displayname, forKey: Constants.UserDetails.DisplayName)
        Constants.staticString.USER_DEFAULTS.setValue( "\(imageurl)", forKey: Constants.UserDetails.imageUrl)
        guard let ViewController =  RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? CompleteProfileVC else { return }
        ViewController.importProfile = true
        self.present(ViewController, animated: true, completion: nil)
    }
    
    //MARK: - fetch profile from Facebook Action
    @IBAction func facebookLoginAction(_ sender: Any) {

        if let token = AccessToken.current, !token.isExpired {
            //user logged in
        }
        
        FBSDKLoginKit.LoginManager().logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            guard error == nil else { return }
            print(result!)
        }
        
    }
    
    //MARK: - Create Profile Manually Button Action
    @IBAction func createManuallyAction(_ sender: Any) {
        guard let ViewController =  RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? CompleteProfileVC else { return }
        ViewController.importProfile = false
        self.navigationController?.pushViewController(ViewController, animated: true)
    }
    

}

extension CreateProfileVC {
    func setupUI() {
        self.createManuallyBtn.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
        self.createManuallyBtn.layer.borderWidth = 1
        self.createManuallyBtn.layer.cornerRadius = self.createManuallyBtn.frame.height / 2
    }
}
