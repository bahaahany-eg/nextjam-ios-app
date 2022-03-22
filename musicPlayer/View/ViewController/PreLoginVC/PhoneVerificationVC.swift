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
    let CountryCode = ["+1", "+7", "+8", "+20", "+27", "+30", "+31", "+32", "+33", "+34", "+36", "+39", "+40", "+41", "+43", "+44", "+45", "+46", "+47", "+48", "+49", "+50", "+51", "+52", "+53", "+54", "+55", "+56", "+57", "+58", "+60", "+61", "+62", "+63", "+64", "+65", "+66", "+81", "+82", "+84", "+86", "+90", "+91", "+92", "+93", "+94", "+95", "+98", "+212", "+213", "+216", "+218", "+220", "+221", "+222", "+223", "+224", "+225", "+226", "+227", "+228", "+229", "+230", "+231", "+232", "+233", "+234", "+235", "+236", "+237", "+238", "+239", "+240", "+241", "+242", "+243", "+244", "+245", "+248", "+249", "+250", "+251", "+252", "+253", "+254", "+255", "+256", "+257", "+258", "+260", "+261", "+262", "+263", "+264", "+265", "+266", "+267", "+268", "+269", "+290", "+291", "+297", "+298", "+299", "+350", "+351", "+352", "+353", "+354", "+355", "+356", "+357", "+358", "+359", "+370", "+371", "+372", "+373", "+374", "+375", "+376", "+377", "+378", "+379", "+380", "+381", "+382", "+385", "+386", "+387", "+389", "+420", "+421", "+423", "+500", "+501", "+502", "+503", "+504", "+505", "+506", "+507", "+509", "+590", "+591", "+592", "+593", "+594", "+595", "+596", "+597", "+598", "+599", "+670", "+672", "+673", "+674", "+675", "+676", "+677", "+678", "+679", "+680", "+681", "+682", "+683", "+685", "+686", "+687", "+688", "+689", "+690", "+691", "+692", "+850", "+852", "+853", "+855", "+856", "+870", "+880", "+886", "+960", "+961", "+962", "+963", "+964", "+965", "+966", "+967", "+968", "+970", "+971", "+972", "+973", "+974", "+975", "+976", "+977", "+992", "+993", "+994", "+995", "+996", "+998"]
    var createAccount : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countryCodeTF.text = CountryCode[0]
        thePicker.dataSource = self
        thePicker.delegate = self
        countryCodeTF.delegate = self
        countryCodeTF.inputView = thePicker
        phoneTF.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor =  UIColor(named: "JAM")
    }
    
    //MARK: - Send Button Action
    @IBAction func SendBtnAction(_ sender: Any) {
        guard let phone = self.phoneTF.text else { return }
        DispatchQueue.main.async {
            self.sendBtn.loadingIndicator(true)
        }
        if phone.count > 0 {
            //MARK: - Login Case Block
            if !createAccount{
                guard let code = self.countryCodeTF.text else { return }
                guard let phone = self.phoneTF.text else { return }
                let Completephone = "\(code)\(phone)"
                let trimmedPhone = Completephone.replacingOccurrences(of: "-", with: "")
                WebLayerUserAPI().getOTP(phone: trimmedPhone)
                self.sendBtn.loadingIndicator(false)
                DispatchQueue.main.async {
                    RouteCoordinator.NavigateToVC(with: "VerifyPhoneVC", Controller: "VerifyPhoneVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: VerifyPhoneVC()) { vc in
                        vc.createNewAccount = false
                        vc.phoneNumber = trimmedPhone
                        Constants.staticKeys.USER_DEFAULTS.setValue(trimmedPhone, forKeyPath: Constants.UserDetails.phoneNumber)
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                }
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
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "Phone number field can't be empty.", style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.sendBtn.loadingIndicator(false)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: "Enter a valid phone no.", style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.sendBtn.loadingIndicator(false)
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
                DispatchQueue.main.async {
                    RouteCoordinator.NavigateToVC(with: "VerifyPhoneVC", Controller: "VerifyPhoneVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: VerifyPhoneVC()) { vc in
                        vc.createNewAccount = true
                        vc.phoneNumber = phoneNumber
                        Constants.staticKeys.USER_DEFAULTS.setValue(phoneNumber, forKeyPath: Constants.UserDetails.phoneNumber)
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                }
            }else {
                let cancel = UIAlertAction(title: "Cancel", style: .cancel){ _ in
                    self.sendBtn.setTitle("Send", for: .normal)
                    self.createAccount = true
                }
                let signIN = UIAlertAction(title: "Try Another", style: .default) { _ in
                    //                    self.createAccount = true
                    //                    self.sendBtn.setTitle("Sign UP", for: .normal)
                }
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Phone Number Exists", Msg: "This phone number has already joined NextJam. Would you like to confirm that's you or enter a different number?", style: .alert, Actions: [cancel,signIN]), animated: true, completion: nil)
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
            self.sendBtn.setTitle("Send", for: .normal)
        }else{
            self.sendBtn.setTitle("Send", for: .normal)
        }
        self.sendBtn.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
        self.sendBtn.layer.borderWidth = 1
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
        self.phoneStack.layer.cornerRadius = self.phoneStack.frame.height / 2
        
        /// Phone Number View
        self.countryCodeTF.ViewLeftCornerRadius(value: Int(self.countryCodeTF.frame.height / 2))
        self.phoneTF.ViewRightCornerRadius(value: Int(self.phoneTF.frame.height / 2))
        self.phoneTF.attributedPlaceholder = NSAttributedString(string: "Phone number...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7)])
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.phoneTF.frame.size.height))
        self.phoneTF.leftView = uiView
        self.phoneTF.leftViewMode = .always
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneTF {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
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

