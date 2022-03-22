//
//  InvitationVC.swift
//  NextJAM
//
//  Created by apple on 25/11/21.
//

import UIKit
import Contacts
import Messages
import MessageUI
import FlagPhoneNumber
import SwiftUI
import Kingfisher

//MARK: - Fetched Contact Model
struct FetchedContact {
//    var firstName: String
//    var lastName: String
    var telephone: String
    var fullname: String
}

class InvitationVC: UIViewController,MFMessageComposeViewControllerDelegate {
   
    
   
    //MARK: - Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btn : UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    
    //MARK: - Variables
//    let composeVC = MFMessageComposeViewController()
    let messageComposer = MessageComposer()

    var segmentIndex : Int = 0
    var contacts = [FetchedContact]()
    var followers = [User]()
    var isContacts = false
    var selected = [Bool]()
    var SelectedContact = [String]()
    var roomID = ""
    var invitationCode = ""
    var roomName = ""
    var username = ""
    var fromparty = true
    var isScheduled = false
    var isfiltered = false
    var filteredContacts = [FetchedContact]()
    var filteredFollowers = [User]()
    var currentPage : Int = 1
    var isSend = false
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchField()
        
        customSegment(selectedIndex:self.segmentIndex, update: false)
        self.tblView.delegate = self
        self.tblView.dataSource = self
//        self.navigationButton(index:self.segmentIndex)
        if segmentIndex == 0 {
//            fetchFollower()
            self.loadUsers(page: self.currentPage)
        }
        if !fromparty{
            DispatchQueue.main.async {
                self.btn.isHidden = true
            }
        }else{
            DispatchQueue.main.async {
                self.btn.isHidden = false
                if self.isScheduled{
                    self.btn.setTitle("Done", for: .normal)
                    self.btn.tag = 100
                }else {
                    self.btn.setTitle("Go to party", for: .normal)
                    self.btn.tag = 200
                }
                self.btn.MakeRound()
            }
        }
        self.title = "Invite your friends"
    }
    
    //MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationButton(index:self.segmentIndex)
        if segmentIndex == 0 {
            self.loadUsers(page: self.currentPage)
        }
    }
    
    
    
    //MARK: - Go To Party Button Action
    @IBAction func GoToPartyAction(_ sender: UIButton) {
        
        if sender.tag == 100{
            RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }else if sender.tag == 200{
            RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: RoomPlayListVC()) { vc in
                vc.fromSessions = false
                vc.AsGuest = false
                vc.roomName = self.roomName
                vc.RoomID = self.roomID
                vc.invitationCode = self.invitationCode
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            
        }
    }
    
    
    //MARK: - Navigation Button Action
    func navigationButton(index:Int){
        let send = UIButton(type: .custom)
        send.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        send.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        send.BarbuttonChangeUX(isCustom: false)
        self.navigationController?.navigationBar.tintColor = UIColor(named: "JAM")
        
        self.navigationController?.navigationBar.barTintColor = .black
        if index == 1{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: send)]
        }else {
            self.navigationItem.rightBarButtonItems?.removeAll()
        }
    }
    
    //MARK: - Send Invitaion Action
    @objc func sendAction(_ sender: UIButton){
        print("Send tapped")
        if isContacts{
//            self.SelectedContact = [self.contacts[sender.tag].telephone]
//            self.composeVC.recipients = self.SelectedContact
//            self.composeVC.body = "Join nextJam via this link: url, here a great party is going on."
//            if MFMessageComposeViewController.canSendText(){
//                DispatchQueue.main.async {
//                    self.present(self.composeVC, animated: true, completion: nil)
//                }
//            }
        }
    }
    
    
    //MARK: - Custom Top Segment
    func customSegment(selectedIndex: Int,update:Bool){
        self.isfiltered = false
        var y = 0
        if UIDevice.current.hasNotch {
            y = Int(self.topbarHeight+40)
        }else {
            y = Int(self.topbarHeight+20)
        }
        let frame = CGRect(x: 0, y: y, width: Int(self.view.frame.width), height: 40)
        let segment = WMSegment(frame: frame)
        segment.type = .normal
        segment.selectorType = .bottomBar
        segment.borderColor = .clear
        segment.buttonTitles = "Followers,Contacts"
        segment.textColor = .white
        segment.selectorTextColor = .white
        segment.selectorColor = #colorLiteral(red: 0.5985194445, green: 0.1699213684, blue: 0.3734838367, alpha: 1)
        segment.selectedSegmentIndex = selectedIndex
        if !update{
            self.view.addSubview(segment)
        }
        segment.onValueChanged = {[self] index in
            print("I have selected index \(index) from Segment")
//            self.navigationButton(index: index)
            self.segmentIndex = index
            print(self.contacts)
            setupSeleted(isfiltered: false)
            reloadData(for: self.segmentIndex)
        }
    }
    
    //MARK: - Reload Data with Segment Index
    func reloadData(for index:Int){
        switch index {
        case 0:
            self.isContacts = false
            loadUsers(page: self.currentPage)
            break
        case 1:
            self.isContacts = true
            fetchContacts()
            break
        default:
            break
        }
    }
    
    
    //MARK: - Setup Selected from the Contact and Followers
    
    func setupSeleted(isfiltered:Bool){
        if isfiltered{
            let c = isContacts ? self.filteredContacts.count : self.filteredFollowers.count
            for i in 0..<c{
                self.selected.append(false)
            }
        }else{
            let c = isContacts ? self.contacts.count : self.followers.count
            if self.currentPage == 1{
                self.selected.removeAll()
                for i in 0..<c{
                    self.selected.append(false)
                }
            }else{
                for i in 0..<c{
                    self.selected.append(false)
                }
            }
            
        }
        
    }
    
    //MARK: - Get app Users
    func loadUsers(page: Int){
        WebLayerUserAPI().FethcPopularUser(page: page) { response in
            print("popular user response++++++++++++++>")
            print(response.users)
            let sorted = self.sortFollower(followers: response.users)
            sorted.forEach {  user in
                self.followers.append(user)
                self.setupSeleted(isfiltered: false)
            }
            self.followers = self.removeDuplicates(from: self.followers)
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        } failure: { error in
            print("ERROR===========\(error.localizedDescription)")
            DispatchQueue.main.async {
                let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                self.present(Utility().showAlert(hasTextField: false, title: "No More data", Msg: "you have fetched all the popular users data", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }

    }
    
    //MARK: - Remove Duplicates from the Followers 
    func removeDuplicates(from:[User]) -> [User] {
        var result = [User]()
        for value in from {
            if result.contains(where: { ele in
                ele.username == value.username
            }) == false{
                result.append(value)
            }
        }
        return result
    }
    

    //MARK: - Fetch Contact from the User Device
    private func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    var temp = [FetchedContact]()
                    self.contacts.removeAll()
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        temp.append(FetchedContact(telephone: contact.phoneNumbers.first?.value.stringValue ?? "", fullname: contact.givenName+" "+contact.familyName))
                    })
                    self.contacts = self.sortContacts(contacts: temp)
                    self.setupSeleted(isfiltered: false)
                    DispatchQueue.main.async{
                        self.tblView.reloadData()
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    
    //MARK: - Sort contacts in alphabatical order
    func sortContacts(contacts: [FetchedContact])->[FetchedContact]{
        var sorted = [FetchedContact]()
        sorted = contacts.sorted{ $0.fullname.localizedCaseInsensitiveCompare($1.fullname) == ComparisonResult.orderedAscending }
        return sorted
    }
    
    func sortFollower(followers:[User])->[User]{
        var sorted = [User]()
        sorted = followers.sorted{ $0.username.localizedCaseInsensitiveCompare($1.username) == ComparisonResult.orderedAscending }
        return sorted
    }
    
    @objc func resend(_ sender : UIButton) {
        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            let uname = self.isfiltered ? self.filteredFollowers[sender.tag].username : self.followers[sender.tag].username
            let params = ["username":uname,
                          "room_id":self.roomID]
            WebLayerUserAPI().sendInvite(username:username,params: params) { staus in
                print(staus)
            } failure: { Error in
                print(Error)
            }
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        
        let alert = Utility().showAlert(hasTextField: false, title: "Resend Invitation", Msg: "Do you want to resend the invitation?", style: .alert, Actions: [yes,no])
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Plus Button Action for TableView Cell
    @objc func AddAction(_ sender: UIButton){
        
        if isContacts{
            
            let plus = UIImage(systemName: "plus")
            let CI = sender.currentImage
            if CI == plus{
                sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
               
            }
        }
        
        if !isContacts{
            if !self.selected[sender.tag] { self.selected[sender.tag].toggle() }
            sender.setTitle("Sent", for: .normal)
            guard let cell = self.tblView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as? InvitationCell else { return }
            cell.resend.isHidden = false
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            let params = ["username":username,
                          "room_id":self.roomID]
            WebLayerUserAPI().sendInvite(username:username,params: params) { staus in
                print(staus)
            } failure: { Error in
                print(Error)
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}


//MARK: - Extension for Tableiview DataSource and Delegate
extension InvitationVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        if isfiltered{
            row = isContacts ? self.filteredContacts.count : self.filteredFollowers.count
        }else{
            row = isContacts ? self.contacts.count : self.followers.count
        }
        return row
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isContacts ? 50 : 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell") as? InvitationCell else { return UITableViewCell.init()}
        if isfiltered{
            if isContacts{
                cell.resend.isHidden =  true
                cell.nameLbl.text = self.filteredContacts[indexPath.row].fullname
                cell.phoneLbl.text = self.filteredContacts[indexPath.row].telephone
                cell.img.isHidden = true
                cell.btn.isHidden = true
            }else{
                cell.img.isHidden = false
                cell.img.backgroundColor = .clear
                guard let  url = self.filteredFollowers[indexPath.row].profileImage as? String else { return UITableViewCell.init()}
                cell.img.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
                cell.img.contentMode = .scaleToFill
                cell.img.MakeRound()
                cell.nameLbl.text = self.filteredFollowers[indexPath.row].username
                cell.phoneLbl.text = self.filteredFollowers[indexPath.row].displayName
                cell.btn.tag = indexPath.row
                cell.btn.addTarget(self, action: #selector(AddAction(_:)), for: .touchUpInside)
                cell.resend.tag = indexPath.row
                cell.resend.addTarget(self, action: #selector(resend(_:)), for: .touchUpInside)
                cell.btn.layer.borderWidth = 0.5
                cell.btn.layer.borderColor = UIColor(named: "JAM")?.cgColor
                if selected[indexPath.row]{
                    cell.btn.setImage(nil, for: .normal)
                    cell.btn.setTitle("Sent", for: .normal)
                    cell.resend.isHidden =  false
                }else {
                    cell.btn.setTitle("Send", for: .normal)
                    cell.btn.setImage(nil, for: .normal)
                    cell.resend.isHidden =  true
                }
            }
        }else{
            if isContacts{
                cell.resend.isHidden =  true
                cell.nameLbl.text = self.contacts[indexPath.row].fullname
                cell.phoneLbl.text = self.contacts[indexPath.row].telephone
                cell.img.isHidden = true
                cell.btn.isHidden = true
            }else{
                cell.img.isHidden = false
                cell.img.backgroundColor = .clear
                guard let url = self.followers[indexPath.row].profileImage as? String else {return UITableViewCell.init()}
                cell.img.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
                cell.img.MakeRound()
                cell.nameLbl.text = self.followers[indexPath.row].username
                cell.phoneLbl.text = self.followers[indexPath.row].displayName
                cell.btn.tag = indexPath.row
                cell.btn.addTarget(self, action: #selector(AddAction(_: )), for: .touchUpInside)
                cell.resend.tag = indexPath.row
                cell.resend.addTarget(self, action: #selector(resend(_:)), for: .touchUpInside)
                cell.btn.layer.borderWidth = 0.5
                cell.btn.layer.borderColor = UIColor(named: "JAM")?.cgColor
                if selected[indexPath.row]{
                    cell.btn.setImage(nil, for: .normal)
                    cell.btn.setTitle("Sent", for: .normal)
                    cell.resend.isHidden =  false
                }else {
                    cell.btn.setTitle("Send", for: .normal)
                    cell.resend.isHidden =  true
                    cell.btn.setImage(nil, for: .normal)
                }
            }
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isContacts{
            if (messageComposer.canSendText()) {
                guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                
                if isfiltered{
                    self.displayMessageInterface(number: self.filteredContacts[indexPath.row].telephone)
                }else{
                    self.displayMessageInterface(number: self.contacts[indexPath.row].telephone)
                }
//                let messageComposeVC = messageComposer.ConfigureMessageViewController(username: username, number: number)
//                present(messageComposeVC, animated: true, completion: nil)
            }
        }
    }
    
    
    func displayMessageInterface(number: String) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.recipients = nil
//        composeVC.recipients?.removeAll()
        // Configure the fields of the interface.
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        composeVC.recipients = [number]
        composeVC.body = "Your have been invited to join NextJam by \(username)\nClick the link below to download the app: https://testflight.apple.com/join/sYqnvlV4"
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
//    Detect when react tableview bottom...
      func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          if !isContacts{
              if indexPath.row == (self.followers.count - 1) {
                  self.currentPage += 1
                  self.loadUsers(page: self.currentPage)
              }
          }
      }
}

//MARK: - Extension for Message Compose ViewController
//extension InvitationVC {
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        switch result {
//        case .cancelled:
////            controller.dismiss(animated: true, completion: nil)
//            break
//        case .sent:
//            self.isSend = true
////            controller.dismiss(animated: true, completion: nil)
//            break
//        case .failed:
//            self.isSend = false
//            break
//        }
//    }
//}



//MARK: - Extension for Search field
extension InvitationVC : UITextFieldDelegate{
    
    func setupSearchField(){
        self.searchField.delegate = self
        self.searchField.autocorrectionType = .no
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let query = textField.text else { return false }
        if query == "" {
            self.isfiltered = false
            resetSearch()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        if query.isEmpty {
            self.isfiltered = false
            resetSearch()
        }else{
            if isContacts{
                isfiltered = true
                self.filteredContacts = self.filterContactWith(query: query)
                self.setupSeleted(isfiltered: true)
                self.tblView.reloadData()
            }else{
                isfiltered = true
                self.filteredFollowers = self.filterFollowersWith(query: query)
                self.setupSeleted(isfiltered: true)
                self.tblView.reloadData()
            }
        }
        return true
    }
    
    func resetSearch(){
        if isContacts {
            self.fetchContacts()
            setupSeleted(isfiltered: false)
        }else {
            self.loadUsers(page: self.currentPage)
            setupSeleted(isfiltered: false)
        }
    }
    
    func filterContactWith(query: String)-> [FetchedContact] {
        var filteredContact = [FetchedContact]()
        let q = query.replacingOccurrences(of: " ", with: "")
        
        filteredContact = self.contacts.filter({ (contact:FetchedContact) ->Bool in
            let fname = contact.fullname.replacingOccurrences(of: " ", with: "").range(of: q, options: .caseInsensitive)
//            let lastName = contact.lastName.range(of:q,options: .caseInsensitive)
            let phone = contact.telephone.range(of: q)
            return fname != nil || phone != nil })
        return filteredContact
    }
    
    func filterFollowersWith(query:String)-> [User] {
        var filteredFollowers = [User]()
        filteredFollowers = self.followers.filter({ (follower:User) -> Bool in
            let username = follower.username.range(of: query,options: .caseInsensitive)
            let displayname = follower.displayName.range(of: query,options: .caseInsensitive)
            return username != nil || displayname != nil })
        return filteredFollowers
    }
    
    
}

