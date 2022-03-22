//
//  PhoneVerificationViewController.swift
//  Pods
//
//  Created by apple on 07/09/21.
//

import UIKit
import FirebaseMessaging

class PhoneVerificationVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var countryCodeTF: UITextField!
    
    @IBOutlet weak var phNumberView: UIView!
    
    @IBOutlet weak var phoneStack: UIStackView!
    
    let thePicker = UIPickerView()
    let CountryCode = ["+1","+91","+93","+213","+376","+264","+268","+374","+247","+43","+242","+880","+375","+32","+501","+229","+441","+975","+591","+387","+267","+55"]
    var createAccount : Bool = false
    let viewContoller = RouteCoordinator.NavigateToVC(with: "VerifyPhoneVC", Controller: "VerifyPhoneVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .automatic) as? VerifyPhoneVC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.phoneTF.text = "111111"
        
        self.phoneTF.placeholder = "Enter phone no..."
        self.countryCodeTF.text = CountryCode[0]
        self.countryCodeTF.inputView = thePicker
        
        thePicker.dataSource = self
        thePicker.delegate = self
        countryCodeTF.delegate = self
        countryCodeTF.inputView = thePicker
        
        setupUI()
    }
    
    
    //MARK: - Send Button Action
    @IBAction func SendBtnAction(_ sender: Any) {
        guard let phone = self.phoneTF.text else { return }
        self.sendBtn.loadingIndicator(true)
        if phone.count > 0 {
            //MARK: - Sing In Case Block
            if !createAccount{
                guard let token = Messaging.messaging().fcmToken else { return }
                guard let url = URL(string: Constants.APIUrls.loginURL) else { return }
                guard let code = self.countryCodeTF.text else { return }
                guard let phone = self.phoneTF.text else { return }
                let Completephone = "\(code)\(phone)"
                let trimmedPhone = Completephone.replacingOccurrences(of: "-", with: "")
                let parameters = [ "phone_number" : trimmedPhone,"fcm_token":token]
                
                self.LoginUserRequest(url: url, parameters: parameters)
            }
            
            //MARK: - Create Account Case Block
            else {
                guard let code = self.countryCodeTF.text else { return }
                guard let phone = self.phoneTF.text else { return }
                let Completephone = "\(code)\(phone)"
                let trimmedPhone = Completephone.replacingOccurrences(of: "-", with: "")
                self.checkAvailability(phoneNumber: trimmedPhone)
            }
        }
        else if phone.count == 0{
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "phone number field can't be empty.", style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "Enter a valid phone no.", style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension PhoneVerificationVC {
    func LoginUserRequest(url: URL, parameters:[String: Any]){
        WebLayerUserAPI().loginUser(url: url, parameters: parameters) { login in
            DispatchQueue.main.async { [self] in
                guard let vc = viewContoller else { return }
                vc.createNewAccount = false
                let userDetails = Constants.UserDetails.self
                let UD = Constants.staticString.USER_DEFAULTS.self
                UD.setValue(login.displayName, forKeyPath: userDetails.DisplayName)
                UD.setValue(login.username, forKeyPath: userDetails.UserName)
                UD.setValue(login.profileImage, forKey: userDetails.imageUrl)
                guard let phone = parameters["phone_number"] as? String else { return }
                UD.setValue(phone, forKeyPath: userDetails.phoneNumber)
                UD.set(true, forKey: Constants.staticString.LoggedInStatus)
                guard let token = Messaging.messaging().fcmToken  else { return }                
                if AppDelegate().sendFCM(token: token){
                    self.sendBtn.loadingIndicator(false)
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
        } failure: { error in
            self.sendBtn.loadingIndicator(false)
            let ok = UIAlertAction(title: "Retry", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "User doesn't exists.", style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Validate Phone Number API CALL
extension PhoneVerificationVC {
    func checkAvailability(phoneNumber:String) {
        
        WebLayerUserAPI().ValidataPhoneNumber(number: phoneNumber) { response in
            print(response)
            DispatchQueue.main.async {
                self.sendBtn.loadingIndicator(false)
            }
            if response {
                DispatchQueue.main.async { [self] in
                    
                    guard let vc = viewContoller else { return }
                    vc.createNewAccount = true
                    Constants.staticString.USER_DEFAULTS.setValue(phoneNumber, forKeyPath: Constants.UserDetails.phoneNumber)
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }else {
                let cancel = UIAlertAction(title: "Cancel", style: .cancel){ _ in
                    self.sendBtn.setTitle("Sign Up", for: .normal)
                    self.createAccount = true
                }
                let signIN = UIAlertAction(title: "Sing In", style: .default) { _ in
                    self.createAccount = false
                    self.sendBtn.setTitle("Sign In", for: .normal)
                }
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Not Available", Msg: "Your account already exists. Please login with your number", style: .alert, Actions: [cancel,signIN]), animated: true, completion: nil)
                }
            }
            
        } failure: { error in
            print(error.localizedDescription)
            let ok = UIAlertAction(title: "Retry", style: .cancel, handler: nil)
            DispatchQueue.main.async {
                self.present(Utility().showAlert(hasTextField: false, title: "Error", Msg: error.localizedDescription, style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }
        
    }
    
}

//MARK: - UI Setup Extension
extension PhoneVerificationVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    func setupUI(){
        /// Send Button
        if !createAccount{
            self.sendBtn.setTitle("Sign In", for: .normal)
        }else{
            self.sendBtn.setTitle("Sign Up", for: .normal)
        }
        self.sendBtn.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
        self.sendBtn.layer.borderWidth = 1
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
        self.phoneStack.layer.cornerRadius = self.phoneStack.frame.height / 2
        
        /// Phone Number View
        self.countryCodeTF.ViewLeftCornerRadius(value: Int(self.countryCodeTF.frame.height / 2))
        self.phoneTF.ViewRightCornerRadius(value: Int(self.phoneTF.frame.height / 2))
    }
    
}

//MARK: - Country Code Picker View Extension
extension PhoneVerificationVC : UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryCode.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return CountryCode[row]
        
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryCodeTF.text = CountryCode[row]
    }
    
}

