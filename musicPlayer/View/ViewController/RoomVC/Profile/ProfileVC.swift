//
//  ProfileVC.swift
//  NextJAM
//
//  Created by apple on 15/09/21.
//

import UIKit
import SwiftUI

class ProfileVC: UIViewController {
    
    ///Outlets
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var displayname: UILabel!
    
    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var FUBtn: UIButton!
    @IBOutlet weak var friendsCollections: UICollectionView!
    
    @IBOutlet weak var topViewHiehgt: NSLayoutConstraint!
    @IBOutlet weak var albumCollection: UICollectionView!
    
    @IBOutlet weak var followerCountLBL: UILabel!
    
    /// Variables
    var uname = ""
    var image = UIImage()
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    var sessions = [Room]()
    var followers = [Followers]()
    var myprofile = false
    var flwrpgCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendsCollections.delegate = self
        self.friendsCollections.dataSource = self
        self.albumCollection.delegate = self
        self.albumCollection.dataSource = self
        self.NavigationButtons()
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.friendsCollections.delegate = self
        self.friendsCollections.dataSource = self
        self.albumCollection.delegate = self
        self.albumCollection.dataSource = self
        
        self.NavigationButtons()
        
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
        
    }
    
    override func willMove(toParent parent: UIViewController?){
        super.willMove(toParent: parent)
        if parent == nil {
            
            
        }
    }
    func getFollowerProfile(){
        getProfile()
    }
    func initialize(){
        self.flwrpgCount = 1
        self.getProfile()
        self.getSession()
        self.getFollowers()
    }
    @IBAction func followUnfollowBtn(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        switch title {
        case "Follow":
            self.followAPI()
            break
        case "Unfollow":
            self.unFolloweAPI()
            break
        default:
            break
        }
    }
    
    ///MARK: - View All button Action
    @IBAction func ViewAllButtonAction(_ sender: Any) {
        RouteCoordinator.NavigateToVC(with: "AttendeesViewController", Controller: "AttendeesViewController", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: AttendeesViewController()) { vc in
            vc.usernm = self.username.text!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: - Navigation Bar Cancel Button
    func NavigationButtons (){
        let EditProfile = UIButton(type: .custom)
        EditProfile.setImage(UIImage(systemName: "square.and.pencil")?.withTintColor(.white), for: .normal)
        EditProfile.addTarget(self, action: #selector(EditProfileAction), for: .touchUpInside)
        self.navigationController?.navigationBar.tintColor = UIColor(named: "JAM")
        self.navigationController?.navigationBar.barTintColor = .black
        
        let home = UIButton(type: .custom)
        home.setImage(UIImage(systemName:"house.fill")?.withTintColor(.white), for: .normal)
        home.tintColor = UIColor(named: "JAM")
        home.addTarget(self, action: #selector(gotoHome), for: .touchUpInside)
        home.BarbuttonChangeUX(isCustom: true)
        
        if myprofile{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: EditProfile),UIBarButtonItem(customView: home)]
        }else{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: home)]
        }
    }
    
    @objc func gotoHome(_ sender:Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Edit Profile Button Action
    @objc func EditProfileAction(sender: UIButton){
        
        RouteCoordinator.NavigateToVC(with: "CompleteProfileVC", Controller: "CompleteProfileVC", Stroyboard: RouteCoordinator.PreLogin, presentation: .fullScreen, ofType: CompleteProfileVC()) { vc in
            vc.isEditingProfile = true
            vc.importProfile = false
            guard let name = self.username.text else { return }
            vc.name = name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: -Update profile vc ui
    func updateUI(){
        self.userProfilePicture.contentMode = .scaleAspectFill
        self.userProfilePicture.MakeRound()
        self.FUBtn.MakeRound()
        self.viewAllBtn.MakeRound()
        if myprofile{
            self.FUBtn.isHidden = true
        }else{
            self.FUBtn.isHidden = false
        }
    }
}

//MARK: - Profile VC Extension for api calls
extension ProfileVC{
    
    func followAPI(){
        guard let followingUsername = self.username.text else { return }
        guard let followerUsername = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{
            return
        }
        WebLayerUserAPI().followed(User: followingUsername, byUser: followerUsername) { isfollowed in
            if isfollowed {
                DispatchQueue.main.async {
                    self.FUBtn.setTitle("Unfollow", for: .normal)
                    self.getProfile()
                    self.getFollowers()
                }
            }
        } failure: { err in
            print(err)
        }
    }
    
    func unFolloweAPI(){
        guard let followingUsername = self.username.text else { return }
        guard let followerUsername = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{
            return
        }
        WebLayerUserAPI().Unfollow(user: followingUsername, byUser: followerUsername) { isUnfollowed in
            if isUnfollowed{
                DispatchQueue.main.async {
                    self.FUBtn.setTitle("Follow", for: .normal)
                    self.getProfile()
                    self.getFollowers()
                }
            }
        } failure: { err in
            print(err)
        }
    }
    
    
    func getProfile(){
        var un = ""
        var my = ""
        if myprofile{
            un = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
            my = un
        }else{
            un = self.uname
            my = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
        }
        WebLayerUserAPI().getProfile(of: un,forUser:my) { [self] profileData in
            DispatchQueue.main.async {
                
                username.text = profileData.username
                displayname.text = profileData.displayName
                self.followerCountLBL.text = "\(profileData.followerCount) Followers"
                if let image = profileData.profileImage as? String {
                    userProfilePicture.sd_setImage(with: URL(string: image), placeholderImage: UIImage(systemName: "person.fill"))
                    userProfilePicture.contentMode = .scaleAspectFill
                }
                if !myprofile{
                    profileData.isFollowing ? FUBtn.setTitle("Unfollow", for: .normal): FUBtn.setTitle("Follow", for: .normal)
                }
            }
        } failure: { error in
            print(error)
        }
    }
    
    
    //MARK: - Get Followers
    func getFollowers(){
        var un = ""
        if myprofile{
            un = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
        }else{
            un = self.uname
        }
        
        WebLayerUserAPI().getFollower(for: un, page: self.flwrpgCount) { fol in
            DispatchQueue.main.async {
                print("response for followers=========>\(fol.users.count)")
                if self.flwrpgCount == 1{
                    self.followers = fol.users
                }else{
                    fol.users.forEach { fl in
                        self.followers.append(fl)
                    }
                }
                
                if self.followers.count == 0 {
                    self.topViewHiehgt.constant = 292 - 118
                }else if self.followers.count <= 6 {
                    self.topViewHiehgt.constant = 292 - 59
                }else if self.followers.count > 6{
                    self.topViewHiehgt.constant = 292
                }
                if self.flwrpgCount <= 2{
                    if fol.users.count == 10 {
                        self.flwrpgCount += 1
                        self.getFollowers()
                    }
                }
                self.friendsCollections.reloadData()
            }
        } failure: { err in
            print(err)
        }
        
    }
    
    //MARK: - Get Sessions
    func getSession(){
        var un = ""
        if myprofile{
            un = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
        }else{
            un = self.uname
        }
        WebLayerUserAPI().fetchSessionForUser(with: un) { sessionsHistory in
            DispatchQueue.main.async {
                if sessionsHistory.rooms.count > 0{
                    self.sessions = sessionsHistory.rooms
                    self.sortSessions()
                }else if sessionsHistory.rooms.count == 0 {
                    self.sessions = []
                    self.albumCollection.reloadData()
                }
            }
            
        } failure: { err in
            print(err)
        }
        
    }
    
    //MARK: - Sort Session by LIVE,SCHEDULED and ENDED order.
    func sortSessions(){
        var tempArr = [Room]()
        var rearrenged = [Room]()
        self.sessions.forEach {
            let uniqueId = $0.roomID
            if !(tempArr.contains(where: {$0.roomID == uniqueId})){
                tempArr.append($0)
            }
            let live = tempArr.filter { $0.roomStatus == "LIVE" }
            let scheduled = tempArr.filter{$0.roomStatus == "SCHEDULED"}
            let ended = tempArr.filter{$0.roomStatus == "ENDED"}
            
            rearrenged = live
            rearrenged += scheduled
            rearrenged += ended
            self.sessions = rearrenged
            DispatchQueue.main.async {
                self.albumCollection.reloadData()
            }
        }
    }
    
    
    fileprivate func loadImage(defaultImage : UIImage?, url : String?, imageView : UIImageView?){
        imageView?.image = defaultImage
        imageLoader.loadImage(url , token: { () -> (Int) in
            return (self.imageIndex ?? 0)
        }) { (success, image) in
            if(!success){
                return
            }
            imageView?.image = image
        }
    }
}


extension ProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Function to assign color to the  status view according to their status
    func StatusColor(Status:String)->UIColor{
        var color = UIColor()
        switch Status.uppercased() {
        case "ENDED":
            color = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        case "LIVE":
            color = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.3254901961, alpha: 1)
        case "SCHEDULED":
            color = #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1)
        default:
            break
        }
        return color
    }
    
    //MARK: - Go to the selected party
    func gotoPlaylist(session:Room,asGuest:Bool){
        RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: RoomPlayListVC()) { vc in
            vc.sessionDetails = session
            vc.AsGuest = asGuest
            vc.fromprofile = true
            if asGuest{
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                let NavigationController = UINavigationController(rootViewController: vc)
                NavigationController.modalPresentationStyle = .fullScreen
                self.present(NavigationController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems : Int = 0
        if collectionView == self.friendsCollections {
            numberOfItems = self.followers.count
        } else if collectionView == self.albumCollection {
            numberOfItems = sessions.count
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var item : UICollectionViewCell!
        if collectionView == self.friendsCollections {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsListCell", for: indexPath) as? FriendsListCell else {
                return UICollectionViewCell.init()
            }
            cell.friendProfileImage.sd_setImage(with: URL(string: self.followers[indexPath.row].profileImage), placeholderImage: UIImage(systemName: "person.fill"))
            cell.MakeRound()
            item =  cell
        }
        else if collectionView == self.albumCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JamSessionCell", for: indexPath) as?  JamSessionCell else { return UICollectionViewCell.init() }
            cell.sessionLbl.text = self.sessions[indexPath.item].roomName
            let date = NSDate(timeIntervalSince1970: Double(self.sessions[indexPath.row].startsAt)!)
            cell.hostedTime.text = Utility().difference(from: date as Date)
            cell.locationLbl.text = self.sessions[indexPath.item].roomStatus
            cell.hostNameLbl.text = "@\(self.sessions[indexPath.row].hostUsername)"
            if let img = self.sessions[indexPath.row].hostProfileImage {
                cell.hostImage.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "person.fill"))
                cell.hostImage.MakeRound()
            }
            cell.statusView.backgroundColor = StatusColor(Status: self.sessions[indexPath.row].roomStatus)
            cell.statusView.MakeRound()
            cell.liveSessionView.layer.cornerRadius = 2
            cell.mmberTimeView.layer.cornerRadius = cell.mmberTimeView.frame.height / 2
            item =  cell
        }
        return item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == albumCollection {
            let session = self.sessions[indexPath.row]
            let un = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
            if un == session.hostUsername {
                self.gotoPlaylist(session:session,asGuest:false)
            }else{
                self.gotoPlaylist(session:session,asGuest:true)
            }
        }
        if collectionView == friendsCollections {
            var profileStatus = Bool()
            guard let usrnm = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            if usrnm == self.followers[indexPath.row].username {
                profileStatus = true
            }else {
                profileStatus = false
            }

            RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { vc in
                vc.uname = self.followers[indexPath.row].username
                vc.myprofile = profileStatus
                vc.initialize()
                //            initialize()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        var size : CGSize = CGSize(width: 0, height: 0)
        if collectionView == self.friendsCollections {
            size = CGSize(width: screenSize.width/7-8, height: screenSize.width/7-8)
        } else if collectionView == self.albumCollection {
            size = CGSize(width: screenSize.width/2-24, height: 260)
        }
        return size
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
