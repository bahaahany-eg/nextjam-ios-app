//
//  SettingsVC.swift

//

import UIKit

class SettingsVC: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var settingsTableView: UITableView!
    
    //MARK: - Variable
    var sectionHeaderTitleArr = ["Account","Assistant","Music"]
    var AccountCellTitle = ["Manage Account","Privacy","Security", "Notification"]
    var Accountimage = ["person","lock.fill","checkmark.seal.fill","bell.fill"]
    var AssistanceImage = ["questionmark.circle.fill","info.circle.fill","rectangle.portrait.and.arrow.right"]
    var AssistanceCellTitle = ["Help", "About","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        settingsTableView.register(UINib(nibName: "connectItunesTableViewCell", bundle: nil), forCellReuseIdentifier: "connectItunesTableViewCell")
        NavigationButtons()
    }
    
    //MARK: - Navigation Buttons Action
    func NavigationButtons(){
        let nav = self.navigationController?.navigationBar
        self.title = "Settings"
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [.foregroundColor: UIColor.white]
        let CancelButton = UIButton(type: .custom)
        CancelButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white), for: .normal)
        CancelButton.setTitle("", for: .normal)
        CancelButton.setTitleColor(UIColor.white, for: .normal)
        CancelButton.addTarget(self, action: #selector(CancelButtonAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: CancelButton)
    }
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Extension for TableView Delegate and Datasource
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else{return UITableViewCell.init()}
            cell.title.text = self.AccountCellTitle[indexPath.row]
            cell.cellImage.image = UIImage(systemName: self.Accountimage[indexPath.row])
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else{return UITableViewCell.init()}
            if indexPath.row == 2 {
                cell.title.textColor = .red
                cell.cellImage.image = UIImage(systemName: self.AssistanceImage[indexPath.row])?.withTintColor(.red)
            }
            cell.title.text = self.AssistanceCellTitle[indexPath.row]
            cell.cellImage.image = UIImage(systemName: self.AssistanceImage[indexPath.row])
            cell.selectionStyle = .none
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "connectItunesTableViewCell", for: indexPath) as? connectItunesTableViewCell else{return UITableViewCell.init()}
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 2 {

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
    func logout(){
        guard let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().logOut(username: username) { Response in
            print(Response)
            DispatchQueue.main.async {
                let vc = RouteCoordinator.NavigateToVC(with: "EntryViewController", Controller: "EntryViewController", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen)
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true) {
                    SharedPlayer.shared.appMediaPlayer.stop()
                    let UD = Constants.staticString.USER_DEFAULTS.self
                    UD.removeObject(forKey: Constants.staticString.LoggedInStatus)
                    UD.removeObject(forKey: Constants.staticString.roomID)
                    UD.removeObject(forKey: Constants.staticString.roomName)
                    UD.removeObject(forKey: Constants.staticString.invitationCode)
                    UD.removeObject(forKey: Constants.staticString.nickname)
                    UD.removeObject(forKey: Constants.UserDetails.DisplayName)
                    UD.removeObject(forKey: Constants.UserDetails.UserName)
                    UD.removeObject(forKey: Constants.UserDetails.imageUrl)
                    UD.removeObject(forKey: Constants.UserDetails.phoneNumber)
                    UD.removeObject(forKey: Constants.staticString.FCMtoken)
                }
            }
             
        } failure: { error in
            print(error)
        }

    }
}
