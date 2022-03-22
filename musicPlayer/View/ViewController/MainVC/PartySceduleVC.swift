//
//  PartySceduleVC.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 16/09/21.
//

import UIKit

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
    override func viewDidLoad() {
        super.viewDidLoad()
        partyInvitesCollectionVw.delegate = self
        partyInvitesCollectionVw.dataSource = self
        partyInvitesCollectionVw.register(UINib(nibName: "AttendeesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AttendeesCollectionViewCell")
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.initialSetup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.BackButton()
        self.CustomTitleView()
        DispatchQueue.main.async {
            self.titleField.frame.size.width = 100
            guard  let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) else {
                self.titleField.text = "Patry title"
                return }
            self.titleField.text = "\(username)'s Party"
        
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
//        let alert = UIAlertController(title: "Creat new room", message: "Enter name below", preferredStyle: .alert)
//
//        let create = UIAlertAction(title: "Start", style: .default) { action in
//            if alert.textFields?.first?.text != "" {
//                Constants.staticString.USER_DEFAULTS.setValue(alert.textFields?.first?.text!, forKey: Constants.staticString.roomName)
//                guard let roomName = alert.textFields?.first?.text else { return }
//                let schedule = self.schedule
//                if schedule == 0 {
//                    self.startParty(RoomName: roomName, schedule: Int(Date().timeIntervalSince1970))
//                }else{
//                    self.startParty(RoomName: roomName, schedule: schedule)
//                }
//            } else if alert.textFields?.first?.text == "" {
//                self.present(alert, animated: true) {
//                    alert.textFields?.first?.placeholder = "Room name can't be empty"
//                }
//            }
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancel)
//        alert.addAction(create)
//        alert.addTextField { text in
//            print(text)
//        }
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
        
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let Start = UIAlertAction(title: "Start", style: .default) { _ in
                guard let roomName = self.titleField.text, self.titleField.text!.count > 0 else { return }
                self.startOrEndPatryBtn.loadingIndicator(true)
                self.startParty(RoomName:roomName , schedule: Int(self.datePicker.date.timeIntervalSince1970))
            }
            guard let title = titleField.text else { return }
            let alert = Utility().showAlert(hasTextField: false, title: title, Msg: "Click start button to continue patry", style: .alert, Actions: [cancel,Start])
        DispatchQueue.main.async {  [self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    func Alert() ->UIViewController{
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        let alert = Utility().showAlert(hasTextField: false, title: "Pending", Msg: "This functionality is yet be implemneted.", style: .alert, Actions: [ok])
        return alert
    }
}

//MARK: - Extension for API Call
extension PartySceduleVC {
    func startParty(RoomName: String,schedule:Int) {
        let userDefaults = Constants.staticString.USER_DEFAULTS
        guard let url = URL(string: Constants.APIUrls.createRoom) else { return }
        guard let username = userDefaults.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        let parameter = [
            "room_name": RoomName,
            "starts_at": schedule
        ] as [String:Any]
        WebLayerUserAPI().createRoom(url: url, parameters: parameter,username: username) { roomDetails in
            print(roomDetails)
            
            let UD = Constants.staticString.USER_DEFAULTS
            guard let nickname = UD.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            SocketIOManager.sharedInstance.establishConnection()
            guard let inCode = roomDetails.inviteCode else {
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                DispatchQueue.main.async {
                    self.startOrEndPatryBtn.loadingIndicator(false)
                    self.present(Utility().showAlert(hasTextField: false, title: "Room not created", Msg: "", style: .alert, Actions: [ok]), animated: true, completion: nil)
                }
                return
            }
            SocketIOManager.sharedInstance.socket.on(clientEvent: .connect) { data, ack in
                SocketIOManager.sharedInstance.connectToServerWithNickName(nickName:nickname, inviteCode:inCode) { list in
                    print("user joined")
                }
            }
            DispatchQueue.main.async {
                self.startOrEndPatryBtn.loadingIndicator(false)
                SocketIOManager.sharedInstance.connectToServerWithNickName(nickName:nickname, inviteCode:inCode) { list in
                    print("user joined")
                }
                guard let vc = RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen) as? RoomPlayListVC else { return }
                vc.AsGuest = false
                guard let id = roomDetails.roomID else { return }
                guard let inCode = roomDetails.inviteCode else { return }
                vc.invitationCode = inCode
                vc.RoomID = id
                vc.roomName = self.titleField.text!
                guard let roomname = self.titleField.text else {return}
                vc.roomName = roomname
                guard  let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else {
                    return
                }
                vc.username = username
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
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
        self.dateView.MakeRound()
        self.startOrEndPatryBtn.MakeRound()
        self.startOrEndPatryBtn.setTitle("Create Party", for: .normal)
        startOrEndPatryBtn.layer.cornerRadius = startOrEndPatryBtn.frame.height/2

    }
    
    //MARK: - Navigation Bar Cancel Button
    func BackButton (){
        let CancelButton = UIButton(type: .custom)
        CancelButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.black), for: .normal)
        CancelButton.setTitle("Cancel", for: .normal)
        CancelButton.setTitleColor(UIColor.black, for: .normal)
        CancelButton.addTarget(self, action: #selector(CancelButtonAction), for: .touchUpInside)
        
        let notification = UIButton(type: .custom)
        notification.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        notification.setTitleColor(.black, for: .normal)
        
        self.navigationController?.navigationBar.tintColor          = .white
        self.navigationController?.navigationBar.barTintColor       = .black
        self.navigationController?.navigationBar.topItem?.title     = self.titleField.text//"Stanley's Party"
        self.navigationItem.rightBarButtonItems     = [UIBarButtonItem(customView: notification)]
        self.navigationItem.leftBarButtonItem       = UIBarButtonItem(customView: CancelButton)
    }
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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
