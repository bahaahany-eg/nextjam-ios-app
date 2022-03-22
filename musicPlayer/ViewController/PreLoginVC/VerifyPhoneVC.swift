//
//  VerifyPhoneViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import OTPFieldView

class VerifyPhoneVC: UIViewController, OTPFieldViewDelegate {
    
    @IBOutlet weak var otpTextfield: OTPFieldView!
    @IBOutlet weak var ContinueBtn: UIButton!
    
    var createNewAccount : Bool = false
    let CreateProfileVC = RouteCoordinator.NavigateToVC(with: "CreateProfileVC", Controller: "CreateProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? CreateProfileVC
    let JamSessionVC = RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen) as? JamSessionVC
    let MusicPermission = RouteCoordinator.NavigateToVC(with: "SubscriptionVC", Controller: "SubscriptionVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen) as? SubscriptionVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOTPField()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    
    @IBAction func verifyAction(_ sender: Any) {
        DispatchQueue.main.async { [self] in
            if self.createNewAccount{
                guard let vc = MusicPermission else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = JamSessionVC else { return }
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
}
extension VerifyPhoneVC {
    func setupOTPField(){
        self.otpTextfield.fieldsCount = 6
        self.otpTextfield.fieldBorderWidth = 2
        self.otpTextfield.defaultBorderColor = .clear
        self.otpTextfield.filledBorderColor = UIColor.green
        self.otpTextfield.defaultBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.otpTextfield.cursorColor = UIColor.red
        self.otpTextfield.displayType = .roundedCorner
        self.otpTextfield.fieldSize = 40
        self.otpTextfield.separatorSpace = 5
        self.otpTextfield.otpInputType = .numeric
        self.otpTextfield.shouldAllowIntermediateEditing = false
        self.otpTextfield.delegate = self
        self.otpTextfield.initializeUI()
        self.otpTextfield.backgroundColor = #colorLiteral(red: 0.0116659496, green: 0.04676222056, blue: 0.09759963304, alpha: 1)
        self.ContinueBtn.layer.cornerRadius = self.ContinueBtn.frame.height / 2
        self.ContinueBtn.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.231372549, blue: 0.3764705882, alpha: 1)
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
        ///after entering values to all boxes this will be called.
        print("entered Value\(otp)")
        
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        print("has entered\(hasEnteredAll)")
        ///after enteredOTP func this will be called.
        return hasEnteredAll
    }
    
    
}
