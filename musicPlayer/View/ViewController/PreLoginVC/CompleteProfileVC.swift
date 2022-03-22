//
//  CompleteProfileViewController.swift
//  NextJAM
//
//  Created by apple on 07/09/21.
//

import UIKit
import FirebaseMessaging
import Alamofire
import SwiftyJSON
import SocketIO


class CompleteProfileVC: UIViewController, UIImagePickerControllerDelegate {
    
    ///Outlets
    @IBOutlet weak var profilePhoto: CustomImageView!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var usernameTF: RoundTextField!
    @IBOutlet weak var displayNameTF: RoundTextField!
    @IBOutlet weak var changePhotoBtn: UIButton!
    
    @IBOutlet weak var controllerTitle: UILabel!
    
    @IBOutlet weak var controllerDescription: UILabel!
    
    ///Variables
    var importProfile : Bool = false
    let imagePicker = ImagePicker()
    var profileURL = ""
    var isEditingProfile = false
    var name = ""
    var importProfilefromFb = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor =  UIColor(named: "JAM")
        initilize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        initilize()
    }
    
    func initilize() {
        if importProfilefromFb {
            guard let urlString = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
            WebLayerUserAPI().fetchImage(url: urlString) { image in
                DispatchQueue.main.async {
                    self.profilePhoto.image = UIImage(data: image)
                }
            }
        }else{
            guard let urlString = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
            let compelete = Constants.APIUrls.GetImage+urlString
            self.profilePhoto.fetchUserImage(imageUrl: compelete)
        }
        if importProfile  {
            //fetch data to show
            self.displayNameTF.text  = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.DisplayName) as? String
            self.usernameTF.text  = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String
            
        }
        
        self.usernameTF.delegate = self
        self.displayNameTF.delegate = self
    }
    
    //MARK: - Back Button Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Change Profile Photo
    @IBAction func changePhotoAction(_ sender: Any) {
        self.imagePicker.delegate = self
        let Camera = UIAlertAction(title: "Camera", style: .default) {_ in
            self.imagePicker.cameraAsscessRequest()
        }
        let Photos = UIAlertAction(title: "Gallery", style: .default) {_ in
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
        guard var username = usernameTF.text else { return }
        guard var displayname = displayNameTF.text else { return }
        guard let phone_number = (Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.phoneNumber)) else { return }
        username = username.trimmingCharacters(in: .whitespaces)
        displayname = displayname.trimmingCharacters(in: .whitespaces)
        if !isEditingProfile{
            if username.isEmpty {
                let ok = UIAlertAction(title: "Ok", style: .default){_ in
                    self.ContinueBtn.setTitle("Continue", for: .normal)
                    self.ContinueBtn.loadingIndicator(false)
                }
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Enter a username", Msg: "Username can't be empty.", style: .alert, Actions: [ok]), animated: true, completion: nil)
                }
            }
            if displayname.isEmpty {
                let ok = UIAlertAction(title: "Ok", style: .default){ _ in
                    self.ContinueBtn.setTitle("Continue", for: .normal)
                    self.ContinueBtn.loadingIndicator(false)
                }
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Enter a Display name", Msg: "Display name can't be empty.", style: .alert, Actions: [ok]), animated: true, completion: nil)
                }
            }
            if !username.isEmpty && !displayname.isEmpty{
                self.registertype2(path: "", displayName: displayname, userName: username, PhoneNumber: "\(phone_number)")
            }
        }else{
            if !username.isEmpty && !displayname.isEmpty{
                self.registertype2(path: "", displayName: displayname, userName: username, PhoneNumber: "\(phone_number)")
            }else{
                let ok = UIAlertAction(title: "Ok", style: .default){ _ in
                    self.ContinueBtn.setTitle("Continue", for: .normal)
                    self.ContinueBtn.loadingIndicator(false)
                }
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Error", Msg: "Enter Username and Display name.", style: .alert, Actions: [ok]), animated: true, completion: nil)
                }
            }
        }
    }
}


extension CompleteProfileVC : UITextFieldDelegate {
    
    
    
}


//MARK: - Register User Api Call
extension CompleteProfileVC {
    //MARK: -Register User API Call
    func registertype2(path:String, displayName:String,userName:String,PhoneNumber:String){
        
        guard let token = Messaging.messaging().fcmToken  else { return }
        
        let param = ["display_name":displayName,
                     "username":userName,
                     "phone_number":PhoneNumber,
                     "fcm_token":token] as [String: Any]
        if let imageData = self.profilePhoto.image?.jpegData(compressionQuality: 0.5) {
            uploadPhotoByApi(image: imageData, parameters: param)
        } else {
            uploadPhotoByApi(image: nil, parameters: param)
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
        if self.isEditingProfile {
            DispatchQueue.main.async{
                self.controllerTitle.text = "Update profile"
                self.controllerDescription.text = ""
                self.ContinueBtn.setTitle("Update", for: .normal)
                self.usernameTF.attributedPlaceholder = NSAttributedString(string: "Username...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7) ])
                self.displayNameTF.attributedPlaceholder = NSAttributedString(string: "Displayname...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7) ])
                let ud = Constants.staticKeys.USER_DEFAULTS
                guard let u =  ud.value(forKey: Constants.UserDetails.UserName) else { return }
                guard let d =  ud.value(forKey: Constants.UserDetails.DisplayName) else { return }
                guard let img =  ud.value(forKey: Constants.UserDetails.imageUrl) else { return }
                
                self.usernameTF.text = "\(u)"
                self.displayNameTF.text = "\(d)"
                guard let url = URL(string: Constants.APIUrls.GetImage+"\(img)") else { return }
                self.profilePhoto.ImageLoader(fromURL: url, placeHolderImage: UIImage(systemName: "person.fill")!)
            }
            
        }else{
            DispatchQueue.main.async{
                self.controllerTitle.text = "Complete profile"
                self.controllerDescription.text = "Finish setting up your profile below."
                self.ContinueBtn.setTitle("Continue", for: .normal)
            }
        }
        self.ContinueBtn.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
        self.ContinueBtn.layer.borderWidth = 1
        self.ContinueBtn.layer.cornerRadius = self.ContinueBtn.frame.height / 2
        self.changePhotoBtn.layer.borderColor = #colorLiteral(red: 0.4676813483, green: 0.1225370392, blue: 0.2480289638, alpha: 1)
        self.changePhotoBtn.layer.borderWidth = 1
        self.changePhotoBtn.layer.cornerRadius = self.changePhotoBtn.frame.height / 2
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
        self.usernameTF.MakeRound()
        self.usernameTF.clipsToBounds = true
        //        self.usernameTF.attributedPlaceholder = NSAttributedString(string: "Username...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7) ])
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


extension CompleteProfileVC {
    private func uploadPhotoByApi(image: Data?, parameters: [String : Any]) {
        if isEditingProfile{
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            let header : HTTPHeader = HTTPHeader(name: "username", value: username)
            AF.upload(multipartFormData: { (MultipartFormData) in
                for (key, value) in parameters {
                    MultipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let data = image  {
                    MultipartFormData.append(data, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            },to: Constants.APIUrls.updateProfile , usingThreshold: UInt64.init(),
                      method: .put, headers: [header]).response { response in
                let status = response.response!.statusCode
                let r = response.result
                print("==========>\n \(JSON(r))\n<=============")
                if status == 200 {
                    switch response.result {
                    case .success (let res):
                        guard let r = res else {
                            DispatchQueue.main.async(execute: {
                                print("Please try again latter!")
                            })
                            return
                        }
                        print(String(data: r, encoding: .utf8))
                        print("Responce ==> \n \(JSON(r)) \n==================================== \n")
                        DispatchQueue.main.async {
                            let UD = Constants.staticKeys.USER_DEFAULTS.self
                            guard let image = JSON(r)["profile_image"] as? Any else {return }
                            guard let username = JSON(r)["username"] as? Any else { return}
                            guard let displayname  = JSON(r)["display_name"] as? Any  else {return }
                            guard let token = JSON(r)["music_api_token"] as? Any else { return }
                            print("parsed=======================>")
                            print("Token======\(token)")
                            print("uname======\(username)")
                            print("dname======\(displayname)")
                            print("img======\(image)")
                            print("parsed=======================>")
                            UD.setValue("\(token)", forKey: Constants.staticKeys.DeveloperToken)
                            UD.setValue("\(image)", forKey: Constants.UserDetails.imageUrl)
                            UD.setValue("\(username)", forKey: Constants.UserDetails.UserName)
                            UD.setValue("\(displayname)", forKey: Constants.UserDetails.DisplayName)
                            UD.set(true, forKey: Constants.staticKeys.LoggedInStatus)
                            self.ContinueBtn.setTitle("Continue", for: .normal)
                            self.ContinueBtn.loadingIndicator(false)
                            let alert = UIAlertController(title: "Profile Updated", message: "Your profile updated successfully.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            print("Server message")
                        })
                    }
                }else{
                    let alert = UIAlertController(title: "Error", message: "Profile not updated", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default){ _ in
                        self.ContinueBtn.setTitle("Update", for: .normal)
                        self.ContinueBtn.loadingIndicator(false)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            AF.upload(multipartFormData: { (MultipartFormData) in
                for (key, value) in parameters {
                    MultipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                if let data = image  {
                    MultipartFormData.append(data, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            },to: Constants.APIUrls.registerUrl , usingThreshold: UInt64.init(),
                      method: .post, headers: nil).response { response in
                let status = response.response!.statusCode
                let r = response.result
                print("==========>\n \(JSON(r))\n<=============")
                if status == 200 {
                    
                    switch response.result {
                    case .success (let res):
                        guard let r = res else {
                            DispatchQueue.main.async(execute: {
                                print("Please try again latter!")
                            })
                            return
                        }
                        print("Responce ==> \n \(JSON(r)) \n==================================== \n")
                        DispatchQueue.main.async {
                            let UD = Constants.staticKeys.USER_DEFAULTS.self
                            guard let image = JSON(r)["profile_image"] as? Any else {return }
                            guard let username = JSON(r)["username"] as? Any else { return}
                            guard let displayname = JSON(r)["display_name"] as? Any  else {return }
                            guard let token = JSON(r)["music_api_token"] as? Any else { return }
                            print("parsed=======================>")
                            print("Token======\(token)")
                            print("uname======\(username)")
                            print("dname======\(displayname)")
                            print("img======\(image)")
                            print("parsed=======================>")
                            UD.setValue("\(token)", forKey: Constants.staticKeys.DeveloperToken)
                            UD.setValue("\(image)", forKey: Constants.UserDetails.imageUrl)
                            UD.setValue("\(username)", forKey: Constants.UserDetails.UserName)
                            UD.setValue("\(displayname)", forKey: Constants.UserDetails.DisplayName)
                            UD.set(true, forKey: Constants.staticKeys.LoggedInStatus)
                            self.ContinueBtn.setTitle("Continue", for: .normal)
                            self.ContinueBtn.loadingIndicator(false)
                            
                            RouteCoordinator.NavigateToVC(with: "FollowYourFavouritePeopleVC", Controller: "FollowYourFavouritePeopleVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: FollowYourFavouritePeopleVC()) { vc in
                                vc.username = "\(username)"
                                self.present(vc, animated: true, completion: nil)
                                
                            }
                            
                            
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            print("Server message")
                        })
                    }
                }else if status == 422{
                    let alert = UIAlertController(title: "Error", message: "Username already exists. Please try with another one.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default){ _ in
                        self.ContinueBtn.setTitle("Continue", for: .normal)
                        self.ContinueBtn.loadingIndicator(false)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
