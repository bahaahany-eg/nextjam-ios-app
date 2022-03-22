//
//  FollowYourFavouritePeopleViewController.swift
//  NextJAM
//
//  Created by apple on 06/09/21.
//

import UIKit
import Kingfisher

class FollowYourFavouritePeopleVC: UIViewController {
    ///Outlets
    @IBOutlet weak var followFavouritePeopleTableView: UITableView!
    
    
    ///Variable
    var currentPage : Int = 1
    var username = ""
    var users = [User]()
    
    var tapped = [Bool]()
    
    
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
            RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell") as? FavCell
        cell?.Display_name.text = self.users[indexPath.row].displayName
        cell?.username.text = self.users[indexPath.row].username
        cell?.followerCount.text = "\(self.users[indexPath.row].followCount) Followers"

        if let url = URL(string:self.users[indexPath.row].profileImage) {
            cell?.userImage.kf.indicatorType = .activity
            cell?.userImage.kf.setImage(with: url, placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
            cell?.userImage.MakeRound()
            cell?.userImage.contentMode = .scaleAspectFill
        }else{
            cell?.userImage.image = UIImage(systemName: "person.fill")
            cell?.userImage.MakeRound()
            cell?.userImage.contentMode = .scaleAspectFit
        }
        
        cell?.followBtn.layer.borderWidth = 3
        cell?.followBtn.layer.borderColor = #colorLiteral(red: 0.467656076, green: 0.1225908324, blue: 0.247995466, alpha: 1)
        cell?.followBtn.layer.cornerRadius = (cell?.followBtn.frame.height)! / 2
        cell?.followBtn.tag = indexPath.row
        cell?.followBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        cell?.followBtn.addTarget(self, action: #selector(followeAction), for: .touchUpInside)
        if self.tapped[indexPath.row] {
            cell?.followBtn.setTitle("Unfollow", for: .normal)
        }else{
            cell?.followBtn.setTitle("Follow", for: .normal)
        }
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
            self.tapped[sender.tag] = true
            // call api to follow user

            self.followAPI(otherUser: self.users[sender.tag].username)
            sender.setTitle("Unfollow", for: .normal)
        } else if sender.currentTitle == "Unfollow" {
            self.tapped[sender.tag] = false
            // call api to unfollow user
            self.unFolloweAPI(otherUser: self.users[sender.tag].username)
            sender.setTitle("Follow", for: .normal)
        }
    }
    
}
extension FollowYourFavouritePeopleVC {
    
    //MARK: - Setup tapped Array
    func setupArray(){
        if self.currentPage == 1 {
            if self.users.count != 0 {
                let count = users.count
                self.tapped.removeAll()
                for _ in 0..<count{
                    self.tapped.append(false)
                }
            }
        }else{
            if self.users.count != 0 {
                let count = users.count
                for _ in 0..<count{
                    self.tapped.append(false)
                }
            }
        }
        
    }
    
    
    //MARK: - Follow API
    func followAPI(otherUser: String)->Bool{
        var status = Bool()
        let followingUsername = otherUser
        let followerUsername = self.username
        WebLayerUserAPI().followed(User: followingUsername, byUser: followerUsername) { isfollowed in
            if isfollowed {
                status = true
            }
        } failure: { err in
            print(err)
            status = false
        }
        return status
    }
    
    //MARK: -Unfollow API
    func unFolloweAPI(otherUser:String)->Bool{
        let followingUsername = otherUser
        var status = Bool()
        let followerUsername = self.username
        WebLayerUserAPI().Unfollow(user: followingUsername, byUser: followerUsername) { isUnfollowed in
            if isUnfollowed{
                status = true
            }
        } failure: { err in
            print(err)
            status = false
        }
        return status
    }
    
    
    //MARK: - Load Popular Users API Call
    func loadUsers(page: Int){
        WebLayerUserAPI().FethcPopularUser(page: page) { response in
            print("popular user response++++++++++++++>")
            print(response.users)
            response.users.forEach { user in
                self.users.append(user)
                self.setupArray()
            }
            DispatchQueue.main.async {
                self.followFavouritePeopleTableView.reloadData()
            }
        } failure: { error in
            print("ERROR===========\(error.localizedDescription)")
            DispatchQueue.main.async {
                let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                self.present(Utility().showAlert(hasTextField: false, title: "No More data", Msg: "you have fetched all the popular users data", style: .alert, Actions: [ok]), animated: true, completion: nil)
            }
        }

    }
}
