//
//  CreateProfileViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import CloudKit
import FBSDKCoreKit
import AuthenticationServices

class CreateProfileVC: UIViewController, GIDSignInDelegate {
    
    
   
    @IBOutlet weak var createManuallyBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
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
   
    
    @IBAction func signInWithAppleBtn(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
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
        guard let fn = user.profile.givenName else { return }
        guard let ln = user.profile.name else { return }
        guard let imageurl = user.profile.imageURL(withDimension: 512) else { return }
        let displayname = fn + " " + ln
        Constants.staticKeys.USER_DEFAULTS.setValue( "", forKey: Constants.UserDetails.UserName)
        Constants.staticKeys.USER_DEFAULTS.setValue( displayname, forKey: Constants.UserDetails.DisplayName)
        Constants.staticKeys.USER_DEFAULTS.setValue( "\(imageurl)", forKey: Constants.UserDetails.imageUrl)

        RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: CompleteProfileVC()) { vc in
            vc.importProfile = true
            vc.isEditingProfile = false
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    //MARK: - fetch profile from Facebook Action
    @IBAction func facebookLoginAction(_ sender: Any) {

        if let token = AccessToken.current, !token.isExpired {
            //user logged inFacebookLogin().LoginResult.success(granted: ["public_profile", "email"], declined: ["public_profile", "email"], token: token)
            
        }
        self.fetchFacebookFields()
        
    }

    
    func fetchFacebookFields() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [ .publicProfile,.email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _):
                let graphReq : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "picture.width(512).height(512), name, email, first_name, last_name"])
                graphReq.start(completionHandler: { (connection, userInfo, error) in
                    
                    if(userInfo != nil)
                    {
                        print(userInfo as Any)
                        //save user id and make entry in database
                        
                        let result = userInfo as! NSDictionary
                        let profile = result["picture"] as! NSDictionary
                        let Profiledata = profile["data"] as! NSDictionary
                        let imageurl = Profiledata["url"] as! String
                        guard let fn = result["first_name"] as? String else { return }
                        guard let ln = result["last_name"] as? String else { return }
                        let displayname = fn + " " + ln
                        Constants.staticKeys.USER_DEFAULTS.setValue( "", forKey: Constants.UserDetails.UserName)
                        Constants.staticKeys.USER_DEFAULTS.setValue( displayname, forKey: Constants.UserDetails.DisplayName)
                        Constants.staticKeys.USER_DEFAULTS.setValue( "\(imageurl)", forKey: Constants.UserDetails.imageUrl)

                        RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: CompleteProfileVC()) { vc in
                            vc.importProfile = true
                            vc.isEditingProfile = false
                            vc.importProfilefromFb = true
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                        loginManager.logOut()

                        
                    }
                    else
                    {
                        
                    }
                })
            }
        }
    }
    
    //MARK: - Create Profile Manually Button Action
    @IBAction func createManuallyAction(_ sender: Any) {
            let storyBoard = UIStoryboard.init(name: "PreLogin", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CompleteProfileVC") as! CompleteProfileVC
            vc.importProfile = false
            vc.isEditingProfile = false
            self.navigationController?.pushViewController(vc, animated: true)
    
    }
}

extension CreateProfileVC {
    func setupUI() {
        self.createManuallyBtn.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
        self.createManuallyBtn.layer.borderWidth = 1
        self.createManuallyBtn.layer.cornerRadius = self.createManuallyBtn.frame.height / 2
    }
}



//MARK: - Extension for Apple Sign In

extension CreateProfileVC:ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!

        }

    
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

            print(error.localizedDescription)

        }
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let appleUserFirstName = appleIDCredential.fullName?.givenName ?? ""
                let appleUserLastName = appleIDCredential.fullName?.familyName ?? ""
                let appleUserEmail = appleIDCredential.email
                let displayName = appleUserFirstName + appleUserLastName
                self.moveForward(displayname:displayName)
            } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
                let appleUsername = passwordCredential.user
                let applePassword = passwordCredential.password
            }

        }

    func moveForward(displayname:String){
        Constants.staticKeys.USER_DEFAULTS.setValue( "", forKey: Constants.UserDetails.UserName)
        Constants.staticKeys.USER_DEFAULTS.setValue(displayname, forKey: Constants.UserDetails.DisplayName)
        Constants.staticKeys.USER_DEFAULTS.setValue( "", forKey: Constants.UserDetails.imageUrl)
        RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: CompleteProfileVC()) { vc in
            vc.importProfile = true
            vc.isEditingProfile = false
            vc.importProfilefromFb = false
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
