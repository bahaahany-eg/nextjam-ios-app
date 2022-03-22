//
//  FollowYourFavouritePeopleViewController.swift
//  NextJAM
//
//  Created by apple on 06/09/21.
//

import UIKit

class FollowYourFavouritePeopleVC: UIViewController {
    ///Outlets
    @IBOutlet weak var followFavouritePeopleTableView: UITableView!
    
    ///Variable
    var currentPage : Int = 0
    let username = ["user"]
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followFavouritePeopleTableView.delegate = self
        followFavouritePeopleTableView.dataSource = self
        followFavouritePeopleTableView.separatorStyle = .none
        
        self.loadUsers(page: self.currentPage)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Done Button Action
    @IBAction func doneButtonAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

//MARK: - TableView dataSource/Delegate Extension
extension FollowYourFavouritePeopleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell") as? FavCell
        cell?.Display_name.text = self.users[indexPath.row].displayName
        cell?.username.text = self.users[indexPath.row].username
        cell?.followerCount.text = "\(self.users[indexPath.row].followCount)k Followers"
        if self.users[indexPath.row].profileImage != ""{
            cell?.userImage.fetchUserImage(imageUrl: "https://lh3.googleusercontent.com/a/AATXAJyifaEQbUS4UdYgwQ2PwhXONmr7qHne79ajA8Mf=s512")
        } else if self.users[indexPath.row].profileImage == "" {
            cell?.userImage.image = UIImage(systemName: "persons.fill")
        }
        cell?.followBtn.layer.borderWidth = 3
        cell?.followBtn.layer.borderColor = #colorLiteral(red: 0.467656076, green: 0.1225908324, blue: 0.247995466, alpha: 1)
        cell?.followBtn.layer.cornerRadius = (cell?.followBtn.frame.height)! / 2
        cell?.followBtn.tag = indexPath.row
        cell?.followBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        cell?.followBtn.addTarget(self, action: #selector(followeAction), for: .touchUpInside)
        cell?.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell!
    }
    
    
  ///Detect when react tableview bottom...
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.users.count - 1) {
            self.currentPage += 1
            self.loadUsers(page: self.currentPage)
        }
    }
    
    //MARK: Follow/Unfollow Button Action
    @objc func followeAction(_ sender: UIButton){
        print(sender.tag)
        if sender.currentTitle == "Follow" {
            sender.setTitle("Unfollow", for: .normal)
        } else if sender.currentTitle == "Unfollow" {
            // call api to unfollow user
            sender.setTitle("Follow", for: .normal)
        }
    }
    
    //MARK: - Load Popular Users API Call
    func loadUsers(page: Int){
        guard let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().FethcPopularUser(page: page, username: username) { response in
            response.users.forEach { user in
                self.users.append(user)
            }
            DispatchQueue.main.async {
                self.followFavouritePeopleTableView.reloadData()
            }
        } failure: { error in
            print(error)
            DispatchQueue.main.async {
                let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                self.present(Utility().showAlert(hasTextField: false, title: "No More data", Msg: "you have fetched all the popular users data", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }

    }
}
