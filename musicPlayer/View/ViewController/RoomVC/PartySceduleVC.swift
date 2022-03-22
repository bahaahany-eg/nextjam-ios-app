//
//  PartySceduleVC.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 16/09/21.
//

import UIKit
import StoreKit
import SwiftUI

class PartySceduleVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var partyInvitesCollectionVw: UICollectionView!
    @IBOutlet weak var inviteFriendsBtn: UIButton!
    @IBOutlet weak var dateAndTimeBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveOrUpdateBtn: UIButton!
    @IBOutlet weak var startOrEndPatryBtn: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    //MARK: - Variable
    let titleField  = UITextField()
    var TitleLable  = ""
    var schedule    = 0
    var patyUsers   = [String]()
    let subController = SKCloudServiceController()
    var hasSubscription = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partyInvitesCollectionVw.delegate = self
        partyInvitesCollectionVw.dataSource = self
        partyInvitesCollectionVw.register(UINib(nibName: "AttendeesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AttendeesCollectionViewCell")
        ProfileButton()
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        self.initialSetup()
        self.titleField.becomeFirstResponder()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.CustomTitleView()
        DispatchQueue.main.async {
            self.titleField.frame.size.width = 130
            guard  let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) else {
                self.titleField.text = "Party title"
                return }
            self.titleField.text = ""
            self.titleField.placeholder = "Session Name"
            self.titleField.delegate = self
        }
        self.DatePicketSetupAndValidation()
    }
    
    
}
//MARK: - Extension for party schedule Time Picker
extension PartySceduleVC {
    
    func DatePicketSetupAndValidation(){
        self.datePicker.date = Date()
        self.datePicker.minimumDate = Date()
        self.datePicker.preferredDatePickerStyle = .compact
    }
    
}
//MARK: - Extension for party Schedule Actions
extension PartySceduleVC {
    //MARK: - Start End Party Button Action
    @IBAction func StartEndAction(_ sender: Any) {
        if self.titleField.text != "" {
            self.checkSchduleParty()
        }else {
            let alert = UIAlertController(title: "Enter Session name", message: "You need to enter a session in order to start it.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                self.titleField.becomeFirstResponder()
            }
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Extension for API Call
extension PartySceduleVC {
    
    //MARK: - Function to check if the party is being started now or a scheduled one
    func checkSchduleParty(){
        let currentTime = Date()
        let selectedDate = self.datePicker.date
        let diff = currentTime.offsetFrom(fromDate: currentTime, toDate: selectedDate)
        let minutesfromDiff = diff/60
        if (minutesfromDiff) < 5 {
            startParty(now: true, interval: Int(selectedDate.timeIntervalSince1970))
        }else{
            startParty(now: false, interval: Int(selectedDate.timeIntervalSince1970))
        }
    }
    
    
    func startParty(now:Bool,interval:Int){
        if !hasSubscription {
            //MARK: - Checking before starting the party if user has the subscription or not.
            self.checkPermission()
        }else{
            if now{
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let Start = UIAlertAction(title: "Start", style: .default) { _ in
                    guard let roomName = self.titleField.text, self.titleField.text!.count > 0 else { return }
                    self.startOrEndPatryBtn.loadingIndicator(true)
                    self.startPartyNow(StartNow: true, RoomName:roomName , schedule: interval)
                }
                guard let title = titleField.text else { return }
                let alert = Utility().showAlert(hasTextField: false, title: title, Msg: "NextJam will notify people that you have started a live party. Are you sure you want to continue?", style: .alert, Actions: [cancel,Start])
                DispatchQueue.main.async {  [self] in
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                let schedule = UIAlertAction(title: "Schedule", style: .default){ _ in
                    guard let roomName = self.titleField.text, self.titleField.text!.count > 0 else { return }
                    self.startOrEndPatryBtn.loadingIndicator(true)
                    self.startPartyNow(StartNow: false, RoomName: roomName, schedule: interval)
                }
                guard let title = titleField.text else { return }
                let alert = Utility().showAlert(hasTextField: false, title: title, Msg: "Click Schedule button to Schedule a new party", style: .alert, Actions: [cancel,schedule])
                DispatchQueue.main.async {  [self] in
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func startPartyNow(StartNow:Bool,RoomName: String,schedule:Int) {
        let userDefaults = Constants.staticKeys.USER_DEFAULTS
        guard let url = URL(string: Constants.APIUrls.createRoom) else { return }
        guard let username = userDefaults.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        let parameter = [
            "room_name": RoomName,
            "starts_at": schedule
        ] as [String:Any]
        WebLayerUserAPI().createRoom(url: url, parameters: parameter,username: username) { roomDetails in
            print(roomDetails)
            if StartNow {
                let UD = Constants.staticKeys.USER_DEFAULTS
                guard let nickname = UD.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                SocketIOManager.sharedInstance.establishConnection()
                guard let inCode = roomDetails.inviteCode else {
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    DispatchQueue.main.async {
                        self.startOrEndPatryBtn.loadingIndicator(false)
                        self.present(Utility().showAlert(hasTextField: false, title: "You have an Active Live Session, Please end the session, before starting a new one!", Msg: "", style: .alert, Actions: [ok]), animated: true, completion: nil)
                    }
                    return
                }
                UD.setValue(inCode, forKey: Constants.staticKeys.invitationCode)
                SocketIOManager.sharedInstance.socket.on(clientEvent: .connect) { data, ack in
                    SocketIOManager.sharedInstance.connectToServerWithNickName(nickName:nickname, inviteCode:inCode) { list in
                        print("user joined")
                    }
                }
                self.startOrEndPatryBtn.loadingIndicator(false)
                SocketIOManager.sharedInstance.connectToServerWithNickName(nickName:nickname, inviteCode:inCode) { list in
                    print("user joined")
                }
                DispatchQueue.main.async {
                    RouteCoordinator.NavigateToVC(with: "InvitationVC", Controller: "InvitationVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: InvitationVC()) { vc in
                        guard let id = roomDetails.roomID else { return }
                        guard let roomname = self.titleField.text else {return}
                        guard  let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                        guard let inCode = roomDetails.inviteCode else { return }
                        vc.roomID = id
                        vc.invitationCode = inCode
                        vc.roomName = roomname
                        vc.username = username
                        vc.isScheduled = !StartNow
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                RouteCoordinator.NavigateToVC(with: "InvitationVC", Controller: "InvitationVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: InvitationVC()) { vc in
                    guard let id = roomDetails.roomID else { return }
                    guard let roomname = self.titleField.text else {return}
                    guard  let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                    guard let inCode = roomDetails.inviteCode else { return }
                    vc.roomID = id
                    vc.invitationCode = inCode
                    vc.roomName = roomname
                    vc.username = username
                    vc.isScheduled = !StartNow
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } failure: { error in
            print(error)
        }
    }
    
}

//MARK: - Extension for Initial setu
extension PartySceduleVC {
    //MARK: - Buttons Initial Setup
    func initialSetup(){
        checkPermission()
        self.dateView.MakeRound()
        self.startOrEndPatryBtn.MakeRound()
        self.startOrEndPatryBtn.setTitle("Create Party", for: .normal)
        startOrEndPatryBtn.layer.cornerRadius = startOrEndPatryBtn.frame.height/2
        
        datePicker.overrideUserInterfaceStyle = .dark
        let bgView = self.datePicker.subviews
        if let dateView = datePicker.subviews.first?.subviews.first?.subviews.first{
            dateView.backgroundColor = UIColor(named: "JAM")
        }
        bgView.forEach { v in
            let v2 = v.subviews
            v2.forEach { v in
                v.backgroundColor = UIColor(named: "JAM")
                v.alpha = 1
            }
        }
        
    }
    //MARK: - Navigation Bar Settings Button
    func ProfileButton (){
        //MARK: - Profile Button
        let profile = UIButton(type: .custom)
        profile.setImage(UIImage(named: "Settings")?.withTintColor(UIColor(named: "JAM")!), for: .normal)
        profile.addTarget(self, action: #selector(ProfileAction), for: .touchUpInside)
        profile.BarbuttonChangeUX(isCustom: true)
        let home = UIButton(type: .custom)
        home.setImage(UIImage(systemName:"house.fill"), for: .normal)
        home.tintColor = UIColor(named: "JAM")
        home.addTarget(self, action: #selector(gotoHome), for: .touchUpInside)
        home.BarbuttonChangeUX(isCustom: true)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profile),UIBarButtonItem(customView: home)]
    }
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func gotoHome(_ sender:Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func ProfileAction(_ sender: Any) {
        
        RouteCoordinator.NavigateToVC(with: "SettingsVC", Controller: "SettingsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: SettingsVC()) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK: - Custom title View
    func CustomTitleView(){
        self.navigationItem.titleView = self.titleField
        self.titleField.frame.size.width = 100
        self.titleField.textAlignment = .center
        self.titleField.backgroundColor = .clear
        self.titleField.textColor = .white
        self.titleField.text = TitleLable
    }
    
}

extension PartySceduleVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patyUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttendeesCollectionViewCell", for: indexPath) as? AttendeesCollectionViewCell else{return UICollectionViewCell.init()}
        cell.attendeesImgVw.image = UIImage(named: "dummy")
        cell.MakeRound()
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.red.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds
        return CGSize(width: size.width/4-16, height: size.width/4-16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
//MARK: - Check Subscriptions and present controller to buy.
extension PartySceduleVC : SKCloudServiceSetupViewControllerDelegate{
    
    //MARK: -Check Permissions
    func checkPermission(){
        let status = SKCloudServiceController.authorizationStatus()
        switch status {
        case .authorized:
            print("autherized")
            self.checkSubscription()
            break
        case .notDetermined:
            SKCloudServiceController.requestAuthorization { _ in
                self.checkPermission()
            }
            break
        default:
            break
        }
    }
    
    
    //MARK: -Check Subscription
    func checkSubscription(){
        subController.requestCapabilities {(capabilities: SKCloudServiceCapability, error: Error?) in
            guard error == nil else {
                print(error)
                print("Doesn't have subsription")
                return }
            if capabilities.contains(.musicCatalogPlayback) {
                print("Has Subscription")
            }else if capabilities.contains(.musicCatalogSubscriptionEligible) && !capabilities.contains(.musicCatalogPlayback){
                print("doesn't have subscription")
                DispatchQueue.main.async{
                    self.hasSubscription = false
                }
                self.showConnectAppleMusicController()
            }
        }
    }
    
    
    //MARK: - Show Subscription Controller
    func showConnectAppleMusicController(){
        let options: [SKCloudServiceSetupOptionsKey: Any] = [.action: SKCloudServiceSetupAction.subscribe]
        let controller = SKCloudServiceSetupViewController()
        controller.delegate = self
        controller.load(options: options) { [weak self] (result: Bool, error: Error?) in
            guard error == nil else { return }
            
            if result {
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
}
