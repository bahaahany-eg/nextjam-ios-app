//
//  SettingsVC.swift

//

import UIKit

class SettingsVC: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var settingsTableView: UITableView!
    
    //MARK: - Variable
    var sectionHeaderTitleArr = ["ACCOUNT","ASSISTANT"]
    var AccountCellTitle = ["Profile","Liked Songs"]
    var Accountimage = ["person","heart"]
    var AssistanceImage = ["lock.fill","info.circle.fill","rectangle.and.pencil.and.ellipsis","square.fill.text.grid.1x2","rectangle.portrait.and.arrow.right"]
    var AssistanceCellTitle = ["Privacy Policy", "Term of service","Feedback","FAQ","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        settingsTableView.register(UINib(nibName: "connectItunesTableViewCell", bundle: nil), forCellReuseIdentifier: "connectItunesTableViewCell")
        NavigationButtons()
        self.settingsTableView.separatorStyle = .singleLine
        self.settingsTableView.separatorColor =  #colorLiteral(red: 0.5764705882, green: 0.5960784314, blue: 0.6470588235, alpha: 0.24)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    //MARK: - Navigation Buttons Action
    func NavigationButtons(){
        let nav = self.navigationController?.navigationBar
        self.title = "Settings"
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(named: "JAM")
    }
    
}

//MARK: - Extension for TableView Delegate and Datasource
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderTitleArr[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.AccountCellTitle.count
        case 1:
            return self.AssistanceCellTitle.count
//        case 2:
//            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else{return UITableViewCell.init()}
            if indexPath.row == 0 {
                guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{ return UITableViewCell.init() }
                cell.username.text = username
                cell.username.textColor = .gray
                cell.title.text = self.AccountCellTitle[indexPath.row]
                cell.cellImage.image = UIImage(named:self.Accountimage[indexPath.row])
                cell.selectionStyle = .none
            }else if indexPath.row == 1{
                cell.username.isHidden = true
                cell.title.text = self.AccountCellTitle[indexPath.row]
                cell.cellImage.image = UIImage(systemName: self.Accountimage[indexPath.row])
                cell.selectionStyle = .none
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else{return UITableViewCell.init()}
            cell.title.text = self.AssistanceCellTitle[indexPath.row]
            cell.cellImage.image = UIImage(systemName: self.AssistanceImage[indexPath.row])
            cell.selectionStyle = .none
            
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { vc in
                    vc.myprofile = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            }else if indexPath.row == 1 {
                RouteCoordinator.NavigateToVC(with: "LikedSongsVC", Controller: "LikedSongsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: LikedSongsVC()) { vc in
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            }
            
            
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                RouteCoordinator.NavigateToVC(with: "PolicyVC", Controller: "PolicyVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: PolicyVC()) { vc in
                    vc.ttl = "Privary Policy"
                    vc.policy = true
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            if indexPath.row == 1 {
                RouteCoordinator.NavigateToVC(with: "PolicyVC", Controller: "PolicyVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: PolicyVC()) { vc in
                    vc.ttl = "Term of Services"
                    vc.policy = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            if indexPath.row == 2{
                RouteCoordinator.NavigateToVC(with: "FeedVC", Controller: "FeedVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: FeedVC()) { vc in
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            if indexPath.row == 3 {
                RouteCoordinator.NavigateToVC(with: "FAQVC", Controller: "FAQVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: FAQVC()) { vc in
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            if indexPath.row == 4 {
                
                let ok = UIAlertAction(title: "Yes", style: .destructive) { _ in
                    self.logout()
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                DispatchQueue.main.async {
                    self.present(Utility().showAlert(hasTextField: false, title: "Logout", Msg: "Do you want to log out from the app?", style: .alert, Actions: [ok,cancel]), animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //MARK: -Function to Logout user from the app
    func logout(){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().logOut(username: username) { Response in
            print(Response)
            DispatchQueue.main.async {
                RouteCoordinator.NavigateToVC(with: "EntryViewController", Controller: "EntryViewController", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: EntryViewController()) { vc in
                    let navigationController = UINavigationController(rootViewController: vc)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true) {
                        SharedPlayer.shared.appMediaPlayer?.stop()
                        let UD = Constants.staticKeys.USER_DEFAULTS.self
                        UD.removeObject(forKey: Constants.staticKeys.LoggedInStatus)
                        UD.removeObject(forKey: Constants.staticKeys.roomID)
                        UD.removeObject(forKey: Constants.staticKeys.roomName)
                        UD.removeObject(forKey: Constants.staticKeys.invitationCode)
                        UD.removeObject(forKey: Constants.staticKeys.nickname)
                        UD.removeObject(forKey: Constants.UserDetails.DisplayName)
                        UD.removeObject(forKey: Constants.UserDetails.UserName)
                        UD.removeObject(forKey: Constants.UserDetails.imageUrl)
                        UD.removeObject(forKey: Constants.UserDetails.phoneNumber)
                        UD.removeObject(forKey: Constants.staticKeys.FCMtoken)
                    }
                }
            }
        } failure: { error in
            print(error)
        }

    }
}
