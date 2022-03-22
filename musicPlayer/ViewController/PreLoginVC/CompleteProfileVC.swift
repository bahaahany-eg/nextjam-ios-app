//
//  CompleteProfileViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import FirebaseMessaging




class CompleteProfileVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    ///Outlets
    @IBOutlet weak var photorequiredAlertText: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var displayNameTF: UITextField!
    @IBOutlet weak var changePhotoBtn: UIButton!
    
    
    ///Variables
    var importProfile : Bool = false
    let imagePicker = ImagePicker()
    var profileURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.changePhotoBtn.isEnabled = false
        if importProfile {
            ///fetch data to show
            self.displayNameTF.text  = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.DisplayName) as? String
            self.usernameTF.text  = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String
            guard let urlString = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
            let compelete = Constants.APIUrls.GetImage+urlString
            self.profilePhoto.fetchUserImage(imageUrl: compelete)
        }
        
        self.imagePicker.delegate = self
    }
    
    //MARK: - Back Button Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Change Profile Photo
    @IBAction func changePhotoAction(_ sender: Any) {
        let Camera = UIAlertAction(title: "Camera", style: .default) {_ in
            self.imagePicker.cameraAsscessRequest()
            
        }
        let Photos = UIAlertAction(title: "Photo Gallary", style: .default) {_ in
            self.imagePicker.photoGalleryAsscessRequest()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sourceSelector = Utility().showAlert(hasTextField: false, title: "Select Source", Msg: "Select a soruce to choose profile image", style: .actionSheet, Actions: [Camera,Photos,cancel])
        DispatchQueue.main.async {
            self.present(sourceSelector, animated: true, completion: nil)
        }
    }
    
    //MARK: - Continue Button Action
    @IBAction func ContinueBtnAction(_ sender: Any) {
        self.ContinueBtn.setTitle("", for: .normal)
        self.ContinueBtn.loadingIndicator(true)
        guard let url = URL(string: Constants.APIUrls.registerUrl) else { return }
        guard let username = usernameTF.text else { return }
        guard let displayname = displayNameTF.text else { return }
        guard let phone_number = (Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.phoneNumber)) else { return }
        if username.isEmpty {
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            DispatchQueue.main.async {
                self.present(Utility().showAlert(hasTextField: false, title: "Enter a username", Msg: "Username can't be empty.", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }
        if displayname.isEmpty {
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            DispatchQueue.main.async {
                self.present(Utility().showAlert(hasTextField: false, title: "Enter a Display name", Msg: "Display name can't be empty.", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }
        self.registertype2(path: "", displayName: displayname, userName: username, PhoneNumber: "\(phone_number)")
    }
}

//MARK: - Register User Api Call
extension CompleteProfileVC {
    //MARK: -Register User API Call
    func registertype2(path:String, displayName:String,userName:String,PhoneNumber:String){
        guard let token = Messaging.messaging().fcmToken  else { return }
        WebLayerUserAPI().uploadImageOne(token:token,username: userName, displayname: displayName, phonenumber: PhoneNumber) { response in
            print(response)
            DispatchQueue.main.async {
                
                self.ContinueBtn.setTitle("Continue", for: .normal)
                self.ContinueBtn.loadingIndicator(false)
                self.present(RouteCoordinator.NavigateToVC(with: "FollowYourFavouritePeopleVC", Controller: "FollowYourFavouritePeopleVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen), animated: true, completion: nil)
                let UD = Constants.staticString.USER_DEFAULTS.self
                let imageData = self.profilePhoto.image?.jpegData(compressionQuality: 0.2)
                let ImageString = String(decoding:imageData!,as:UTF8.self)
                UD.setValue(ImageString, forKey: Constants.UserDetails.imageUrl)
                UD.setValue(userName, forKey: Constants.UserDetails.UserName)
                UD.setValue(displayName, forKey: Constants.UserDetails.DisplayName)
                UD.setValue(PhoneNumber, forKey: Constants.UserDetails.phoneNumber)
                UD.set(true, forKey: Constants.staticString.LoggedInStatus)
                
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.ContinueBtn.setTitle("Continue", for: .normal)
                self.ContinueBtn.loadingIndicator(false)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                self.present(Utility().showAlert(hasTextField: false, title: "Error", Msg: "\(error)", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }
    }
}
//MARK: - UI Setup Extension
extension CompleteProfileVC{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    
    func setupUI(){
        self.ContinueBtn.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
        self.ContinueBtn.layer.borderWidth = 1
        self.ContinueBtn.layer.cornerRadius = self.ContinueBtn.frame.height / 2
        self.changePhotoBtn.layer.borderColor = #colorLiteral(red: 0.6494693756, green: 0.1685312688, blue: 0.3700034618, alpha: 1)
        self.changePhotoBtn.layer.borderWidth = 1
        self.changePhotoBtn.layer.cornerRadius = self.changePhotoBtn.frame.height / 2
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
        if self.profilePhoto.hasContent {
            self.photorequiredAlertText.isHidden = true
            let _ = self.photorequiredAlertText.heightAnchor.constraint(equalToConstant: 0)
        } else {
            self.photorequiredAlertText.isHidden = false
        }
        
        self.displayNameTF.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7) ])
        self.usernameTF.attributedPlaceholder = NSAttributedString(string: "@handle", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7) ])
    }
    
}

//MARK: - Image Picker Extension
extension CompleteProfileVC : ImagePickerDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        self.profilePhoto.image = image
        self.profilePhoto.contentMode = .scaleAspectFill
        self.imagePicker.dismiss()
    }

   
    func cancelButtonDidClick(on imageView: ImagePicker) {
        imagePicker.dismiss()
    }
    
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool, to sourceType: UIImagePickerController.SourceType) {
        guard grantedAccess else { return }
        self.imagePicker.present(parent: self, sourceType: sourceType)
    }
}
