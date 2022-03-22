//
//  VerifyPhoneViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import OTPFieldView
import FirebaseMessaging
class VerifyPhoneVC: UIViewController, OTPFieldViewDelegate {
    
    @IBOutlet weak var otpTextfield: OTPFieldView!
    @IBOutlet weak var ContinueBtn: UIButton!
    
    var otp = ""
    var phoneNumber = ""
    var createNewAccount : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOTPField()
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
    
    @IBAction func verifyAction(_ sender: Any) {
        
        guard let otp = self.otp as? String else {
            DispatchQueue.main.async {
                self.alert(message: "Please check OTP.", Title: "Error")
                return
            }
        }
        
        WebLayerUserAPI().verifyOTP(forPhone:self.phoneNumber, otp: otp) { status, message in
            if status {
                DispatchQueue.main.async { [self] in
                    if self.createNewAccount{
                        RouteCoordinator.NavigateToVC(with: "SubscriptionVC", Controller: "SubscriptionVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: SubscriptionVC()) { vc in
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.LoginUserRequest()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.alert(message: "Invalid verification code.", Title: "Error")
                }
            }
        }
        
    }
    
    func LoginUserRequest(){
        guard let urlString = Constants.APIUrls.loginURL as? String else { return }
        guard let token = Messaging.messaging().fcmToken else { return }
        let parameters = [ "phone_number" : self.phoneNumber,"fcm_token":token]
        guard let url = URL(string: urlString) else { return }
        WebLayerUserAPI().loginUser(url: url, parameters: parameters) { login in
            DispatchQueue.main.async {
                RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                    print(login)
                    let userDetails = Constants.UserDetails.self
                    let UD = Constants.staticKeys.USER_DEFAULTS.self
                    UD.setValue(login.displayName, forKeyPath: userDetails.DisplayName)
                    UD.setValue(login.username, forKeyPath: userDetails.UserName)
                    UD.setValue(login.profileImage, forKey: userDetails.imageUrl)
                    UD.setValue(login.musicAPIToken, forKey: Constants.staticKeys.DeveloperToken)
                    guard let phone = parameters["phone_number"] as? String else { return }
                    UD.setValue(phone, forKeyPath: userDetails.phoneNumber)
                    UD.set(true, forKey: Constants.staticKeys.LoggedInStatus)
                    guard let token = Messaging.messaging().fcmToken  else { return }
                    if AppDelegate().sendFCM(token: token){
                        self.ContinueBtn.loadingIndicator(false)
                        let nC = UINavigationController(rootViewController: vc)
                        nC.modalPresentationStyle = .fullScreen
                        self.present(nC, animated: true, completion: nil)
                    }
                }
            }
        } failure: { error in
            self.ContinueBtn.loadingIndicator(false)
            let ok = UIAlertAction(title: "Retry", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "\(error)" , style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
extension VerifyPhoneVC {
    func setupOTPField(){
        self.otpTextfield.fieldsCount = 6
        self.otpTextfield.fieldBorderWidth = 2
        self.otpTextfield.defaultBorderColor = .clear
        self.otpTextfield.filledBorderColor = #colorLiteral(red: 0.4750336409, green: 0.1259867251, blue: 0.2521235645, alpha: 1)
        self.otpTextfield.defaultBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.otpTextfield.cursorColor = UIColor.red
        self.otpTextfield.displayType = .roundedCorner
        self.otpTextfield.fieldSize = 54
        self.otpTextfield.separatorSpace = 5
        self.otpTextfield.otpInputType = .numeric
        self.otpTextfield.shouldAllowIntermediateEditing = false
        self.otpTextfield.delegate = self
        self.otpTextfield.initializeUI()
        self.otpTextfield.backgroundColor = .clear
        self.ContinueBtn.layer.cornerRadius = self.ContinueBtn.frame.height / 2
        self.ContinueBtn.backgroundColor = #colorLiteral(red: 0.4750336409, green: 0.1259867251, blue: 0.2521235645, alpha: 1)
        
        if self.isDarkMode{
            self.otpTextfield.filledBackgroundColor = UIColor.clear
        }else {
            self.otpTextfield.filledBackgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String) {
        ///after entering values to all boxes this will be
        self.otp = otp
        print("entered Value\(otp)")
        
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        print("has entered\(hasEnteredAll)")
        ///after enteredOTP func this will be called.
        return hasEnteredAll
    }
    
    
}
