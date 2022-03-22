//
//  RoomPlayListVC.swift
//  NextJAM
//
//  Created by apple on 16/09/21.
//

import UIKit
import CoreData
import Loady
import StoreKit
import MediaPlayer
import AVFoundation


class RoomPlayListVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var Role: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var totalMbmLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var joinNowBtn: LoadyButton!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var JoinButtonView: UIView!
    @IBOutlet weak var playingSongtitle: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    
    @IBOutlet var nowPlayingImage: [UIImageView]!
    @IBOutlet var nowPlayingTitle: [UILabel]!
    
    //MARK: - Variables
    var AsGuest = false
    var joined = false
    var RoomID = ""
    var roomName = ""
    var invitationCode = ""
    var username = ""
    var userType = ""
    var sessionDetails : Room?
    var fromNotification = false
    var HostName  = ""
    var playlist : PlayListModel!

    var songArray: [SongDetails] = []
    var applicationMusicPlayer =  SharedPlayer.shared.appMediaPlayer

    var isLoading = false
    let spinner = UIActivityIndicatorView(style: .medium)

    
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NavigationButtons()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.songArray.removeAll()
        fetchSongfromServer()
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.tapAction (_:)))
        self.PlayerView.addGestureRecognizer(tapGesture)
        
        
        let userDefaults = Constants.staticString.USER_DEFAULTS
        userDefaults.setValue(self.sessionDetails?.inviteCode, forKey: Constants.staticString.invitationCode)
        userDefaults.setValue(self.RoomID, forKey: Constants.staticString.roomID)
        
        //MARK: - Adding Socket Handlers for music_search listner
        self.searchListener(called :"viewDidLoad/ playlistVC")
        
        self.SessionEndListner()
        self.UpdateNowPlayingListner()
        self.checkRole(isGuest: AsGuest)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchSongfromServer), name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.updateSocketStatus), name: NSNotification.Name(rawValue: "connectionStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSongtitle), name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
        
        let gesture = UIGestureRecognizer(target: self, action: #selector(showHostProfile(_:)))
        self.userImage.addGestureRecognizer(gesture)
        
        
        if !AsGuest {
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = "Not Playing"
            }
            self.nowPlayingImage.forEach { imgView in
                imgView.image =  UIImage(named: "NextJamLogo")
                if imgView.tag == 100 {
                    imgView.alpha  = 0.5
                }
                
            }
            
        } else {
            fetchSongfromServer()
            //code for guest user goes here...
        }
      
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: false)

        if AsGuest{
            self.title = self.sessionDetails?.roomName
            fetchSongfromServer()
        }
        else {
            self.title = self.roomName
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSongtitle()
        
        if self.songArray.count != 0 {
            if applicationMusicPlayer.playbackState == .playing || applicationMusicPlayer.playbackState == .paused {
                self.nowPlayingTitle.forEach { lbl in
                    lbl.text = applicationMusicPlayer.nowPlayingItem?.title
                }
                self.nowPlayingImage.forEach { imgView in

                    if let index = SharedPlayer.shared.currentSongIndex {
                        loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: SharedPlayer.shared.array[index].songImage, imageView: imgView)
                    }

                }
            }
        } else {
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = "Not Playing"
            }
            self.nowPlayingImage.forEach { imgView in
                imgView.image =  UIImage(named: "NextJamLogo")
            }
        }
        
        
    }
    
    //MARK: - Hosting Button Action
    @objc func showHostProfile(_ sender: Any) {
        let vc = RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen)
        let NavigationController = UINavigationController(rootViewController: vc)
        NavigationController.modalPresentationStyle = .fullScreen
        self.present(NavigationController, animated: true, completion: nil)
    }
    
    //MARK: - Update Connection Status
    @objc func updateSocketStatus(sender: NSNotification){
        guard let status = sender.object as? Bool else { return }
        if status {
            self.title = "Connecting..."
        }else {
            if AsGuest{
                self.title = self.sessionDetails?.roomName
            }
            else {
                self.title = self.roomName
            }
            
        }
    }
    
    
    //MARK: - Like Button Action
    @IBAction func likeBtnAction(_ sender: UIButton) {
        
    }
    
    
    //MARK: - Add Button Action
    @IBAction func addBtnAction(_ sender: UIButton) {
        SKCloudServiceController.requestAuthorization { [self] (status) in
            if status == .authorized {
                let vc = RouteCoordinator.NavigateToVC(with: "SearchVC", Controller: "SearchVC", Stroyboard: RouteCoordinator.Main, presentation: .automatic) as! SearchVC
                vc.delegate = self
                if !self.AsGuest{
                    vc.userType = self.userType
                    vc.inviteCode = self.invitationCode
                    vc.roomId = self.RoomID
                } else{
                    guard let session  = self.sessionDetails else { return }
                    vc.userType = self.userType
                    vc.inviteCode = session.inviteCode
                    vc.roomId = session.roomID
                }
                self.present(vc, animated: true, completion: nil)
            }
            else{
                print("")
            }
        }
    }
    
    @IBAction func forwardBtnAction(_ sender: UIButton) {
        self.applicationMusicPlayer.skipToNextItem()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: false)
    }
    
    //MARK: - Join Room Button Action
    @IBAction func joinButtonAction(_ sender: Any) {
        let userDefaults = Constants.staticString.USER_DEFAULTS
        guard let username = userDefaults.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        self.joinRoom(username: username)
    }
    
    //MARK: - Join Room Action
    func joinRoom(username:String){
        let userDefaults = Constants.staticString.USER_DEFAULTS
        guard let sessionInfo = self.sessionDetails else { return }
        userDefaults.set(sessionInfo.inviteCode, forKey: Constants.staticString.invitationCode)
        userDefaults.set(sessionInfo.roomName, forKey: Constants.staticString.roomName)
        userDefaults.set(sessionInfo.roomID, forKey: Constants.staticString.roomID)
        SocketIOManager.sharedInstance.connectToServerWithNickName(nickName: username, inviteCode: sessionInfo.inviteCode) { list in
            print(list)
        }
        onGuestJoin()
        Constants.staticString.USER_DEFAULTS.set(sessionInfo.inviteCode, forKey: Constants.staticString.invitationCode)
    }
    
    //MARK: - New Memeber joined Event listner
    func onGuestJoin(){
        SocketIOManager.sharedInstance.socket.on("new_member") {[self] data, ack in
            if AsGuest {
                joined = true
                checkRole(isGuest: AsGuest)
            }
        }
        
    }
}

//MARK: - RoomPlayListVC Private Extension
private extension RoomPlayListVC {
    //MARK: - Back Button UI
    func NavigationButtons(){
        let CancelButton = UIButton(type: .custom)
        CancelButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white), for: .normal)
        CancelButton.setTitleColor(UIColor.white, for: .normal)
        CancelButton.addTarget(self, action: #selector(CancelButtonAction), for: .touchUpInside)
        let profileButton = UIButton(type: .custom)
        profileButton.setImage(UIImage(named: "person")?.withTintColor(.white), for: .normal)
        profileButton.setTitleColor(UIColor.white, for: .normal)
        profileButton.addTarget(self, action: #selector(GoToProfile), for: .touchUpInside)
        let closeSession = UIButton(type: .custom)
        closeSession.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeSession.setTitleColor(UIColor.white, for: .normal)
        closeSession.addTarget(self, action: #selector(EndSessionAction), for: .touchUpInside)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        if !AsGuest{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: closeSession)]
            
        } else if AsGuest{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: CancelButton)
        }
    }
    
    //MARK: - Move to Settings Screen
    @objc func GoToProfile(_ sender:UITapGestureRecognizer){
        DispatchQueue.main.async {
            let vc = RouteCoordinator.NavigateToVC(with: "SettingsVC", Controller: "SettingsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        if fromNotification{
            let vc = RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen)
            self.navigationController?.setViewControllers([vc], animated: true)
            ClearJoinSessionDetails()
        }else {
            self.dismiss(animated: true) {
                self.ClearJoinSessionDetails()
            }
        }
    }
    
    
    //MARK: - Clear Session Details

    func ClearJoinSessionDetails(){
        Constants.staticString.USER_DEFAULTS.removeObject(forKey: Constants.staticString.invitationCode)
        Constants.staticString.USER_DEFAULTS.removeObject(forKey:Constants.staticString.roomName)
        Constants.staticString.USER_DEFAULTS.removeObject(forKey:Constants.staticString.roomID)
        
        
        SharedPlayer.shared.appMediaPlayer.pause()
        SharedPlayer.shared.isPaused = true
        SharedPlayer.shared.array = []
        SharedPlayer.shared.timer?.invalidate()
        SharedPlayer.shared.appMediaPlayer.nowPlayingItem = nil
    }
    
    //MARK: -End Session Action
    @objc func EndSessionAction(){
        let End = UIAlertAction(title: "Yes", style: .destructive) { _ in
            //MARK: - Exit from Session
            self.tblView.delegate = nil
            self.tblView.dataSource = nil
            SocketIOManager.sharedInstance.exitFromSocketWithNickName(nickname: Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String, roomid:Constants.staticString.USER_DEFAULTS.value(forKey: Constants.staticString.roomID) as! String) {
                print("exitted from the room")
            }
            //MARK: - End CurrentSession
            self.dismiss(animated: true) {
                self.applicationMusicPlayer.stop()
                self.ClearJoinSessionDetails()
            }
        }
        let cancel = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        DispatchQueue.main.async {
            self.present(Utility().showAlert(hasTextField: false, title: "End Session", Msg: "Do you want to end session?", style: .alert, Actions: [End,cancel]), animated: true, completion: nil)
        }
    }
    
    //MARK: - Show Music Player Action
    @objc func tapAction(_ sender:UITapGestureRecognizer){
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else {
            if !AsGuest {
                DispatchQueue.main.async { [self] in
                    
                    if SharedPlayer.shared.appMediaPlayer.nowPlayingItem != nil  {
                        let vc  = RouteCoordinator.NavigateToVC(with: "PlayerViewController", Controller: "PlayerViewController", Stroyboard: RouteCoordinator.Player, presentation: .fullScreen) as! PlayerViewController

                        SharedPlayer.shared.array = self.songArray
                        SharedPlayer.shared.isBoolNextOneTime = false

                        self.present(vc, animated: true, completion: nil)
                    } else {
                        
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        let alert = Utility().showAlert(hasTextField: false, title: "Item not playing!", Msg: "", style: .alert, Actions: [ok])
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
            }
            return
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let goToMusic = UIAlertAction(title: "Go To Music", style: .default) { _ in
            UIApplication.shared.openURL(NSURL(string: "itms-apps://apple.com/app/id1108187390r?mt=8&uo=4")! as URL)
        }
        let alert = Utility().showAlert(hasTextField: false, title: "Opps!!!", Msg: "This device doesn't have a active apple music subscription.", style: .alert, Actions: [cancel, goToMusic])
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //MARK: -fetch playlist sogns
    @objc func fetchSongfromServer() {
        var roomid = ""
        if AsGuest{
            guard let session = sessionDetails else { return }
            roomid = session.roomID
        }else {
            roomid = self.RoomID
        }
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
        WebLayerUserAPI().fetchSongsListFromServer(roomId: roomid) {[self] songslist in
            self.songArray = songslist.songs
            SharedPlayer.shared.array = songslist.songs
            DispatchQueue.main.async { self.tblView.reloadData() }
        } failure: { Error in
            print(Error)
        }
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    //MARK: - Check Role Action
    func checkRole(isGuest: Bool){
        if isGuest {
            self.JoinButtonView.isHidden = joined
        }else{
            self.JoinButtonView.isHidden = true
            self.PlayerView.isHidden = false
            let UD = Constants.staticString.USER_DEFAULTS.self
            guard let username = UD.value(forKey: Constants.UserDetails.UserName) as? String else {return}
            self.joinRoom(username: username)
        }
    }
    
    //MARK: - Show Music Player
    @objc func ShowPlayer(sender: UIGestureRecognizer) {
        DispatchQueue.main.async {
//            let vc = RouteCoordinator.NavigateToVC(with: "PlayerViewController", Controller: "PlayerViewController", Stroyboard: RouteCoordinator.Player, presentation: .fullScreen) as! PlayerViewController
//            vc.array = self.songArray
//            print("Printed from \(#function)")
//            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    //MARK: - Setup ViewController UI
    func setupUI(){
        if fromNotification{
            if AsGuest{
                self.nameLB.text = self.HostName
//                guard let hostname = self.sessionDetails?.hostDisplayName else { return }
                self.Role.text = "@\(self.HostName)"
            }else {
                guard let image = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
                guard let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                guard let displayName = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.DisplayName) as? String else { return }
                self.nameLB.text = username
                self.Role.text = "@\(displayName)"
                
            }
        } else {
            if AsGuest{
                self.nameLB.text = self.sessionDetails?.hostUsername
                guard let hostname = self.sessionDetails?.hostDisplayName else { return }
                self.Role.text = "@\(hostname)"
            }else {
                guard let image = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
                guard let username = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                guard let displayName = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.DisplayName) as? String else { return }
                self.nameLB.text = username
                self.Role.text = "@\(displayName)"
                
            }
        }
        
        
        self.likeBtn.MakeRound()
        self.userImage.MakeRound()
        self.userImage.layer.borderWidth = 2
        self.userImage.layer.borderColor = #colorLiteral(red: 0.5985194445, green: 0.1699213684, blue: 0.3734838367, alpha: 1)
        self.likeBtn.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        self.joinNowBtn.MakeRound()
    }
    
    //MARK: - Update Now Playing Label on changes
    @objc func updateSongtitle(){
        self.nowPlayingTitle.forEach { lbl in
            lbl.text = self.applicationMusicPlayer.nowPlayingItem?.title
        }
        self.nowPlayingImage.forEach { imgView in
            imgView.image =  UIImage(named: "NextJamLogo")
        }
    }
}

extension RoomPlayListVC: SearchVCProtocol {
    func getSongListDelegateMethod() {
        fetchSongfromServer()
    }
}

//MARK: - Playlist Table View Delegate & DataSource
extension RoomPlayListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AsGuest {
        case true:
            return self.songArray.count
        case false:
            return self.songArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomPlayListCell") as? RoomPlayListCell else { return UITableViewCell.init() }
        
        if self.songArray.count != 0 {
            loadImage(defaultImage : UIImage.init(named: ""), url : self.songArray[indexPath.row].songImage, imageView: cell.albumImage)
        }
        
        switch AsGuest {
        case true:
            cell.songTitle.text  =  self.songArray[indexPath.row].name
            cell.artistName.text =  self.songArray[indexPath.row].artistName
            cell.UserAddingSngImg.MakeRound()
            cell.userAddingSngName.text = self.songArray[indexPath.row].userData.username
            cell.albumImage.layer.borderColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
            cell.albumImage.layer.borderWidth = 2
            cell.selectionStyle = .none
            return cell
        case false:
            cell.songTitle.text  = self.songArray[indexPath.row].name
            cell.artistName.text = self.songArray[indexPath.row].artistName
            cell.albumImage.layer.borderColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
            cell.albumImage.layer.borderWidth = 2
            cell.UserAddingSngImg.MakeRound()
            cell.userAddingSngName.text = self.songArray[indexPath.row].userData.username
            if let image = self.songArray[indexPath.row].userData.profileImage as? String {
                cell.UserAddingSngImg.imageFromServerURL(imageName: image, PlaceHolderImage: (UIImage(systemName: "person")?.withTintColor(.white))!)
            }else {
                cell.UserAddingSngImg.image = UIImage(systemName: "person")?.withTintColor(.white)
            }
            cell.selectionStyle = .none
            return cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !AsGuest {
            self.nowPlayingImage.forEach { imgView in
                self.loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: self.songArray[indexPath.row].songImage, imageView: imgView)
            }
            
            /*
            let PlayerVC = PlayerViewController.shared
            GlobalManager.shared.index = indexPath.row
            PlayerVC.invitation = self.invitationCode
            PlayerVC.array = self.songArray
            PlayerVC.initilize()
            self.show(PlayerVC, sender: self)
             */

            let vc = RouteCoordinator.NavigateToVC(with: "PlayerViewController", Controller: "PlayerViewController", Stroyboard: RouteCoordinator.Player, presentation: .fullScreen) as! PlayerViewController
            vc.isComeFrom = "PlaySong"

            
            SharedPlayer.shared.appMediaPlayer.pause()
            SharedPlayer.shared.isPaused = true
            SharedPlayer.shared.array = []
            SharedPlayer.shared.timer?.invalidate()
            SharedPlayer.shared.appMediaPlayer.nowPlayingItem = nil
                        
            SharedPlayer.shared.currentSongIndex = indexPath.row
            SharedPlayer.shared.invitation = self.invitationCode
            SharedPlayer.shared.array = self.songArray
            SharedPlayer.shared.isBoolNextOneTime = false
            

            self.present(vc, animated: true, completion: nil)
        }
    }
    
    ///Detect when react tableview bottom...
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastSectionIndex = tableView.numberOfSections - 1
//        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
//
//        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
//            self.spinner.startAnimating()
//            self.fetchSongfromServer()
//            self.spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
//            self.tblView.tableFooterView = spinner
//            self.tblView.tableFooterView?.isHidden = false
//        }
//    }
    
}

//MARK: - Socket Event Handler
extension RoomPlayListVC {
    func UpdateNowPlayingListner(){
        SocketIOManager.sharedInstance.socket.on("update_currently_playing") { [self]
            data, ack in
            print("Current Playing song-----")
            print(data)
            guard let nowPlaying = (data[0] as? Dictionary<String,Any>)!["song_name"] as? String else { return }
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = nowPlaying
            }
            self.nowPlayingImage.forEach { imgView in
                self.songArray.forEach { song in
                    if song.name == nowPlaying{
                        loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: song.songImage, imageView: imgView)
                    }
                    
                    
                }
            }
        }
    }
    
    func SessionEndListner(){
        if AsGuest{
            SocketIOManager.sharedInstance.socket.on("close_room") {[self] data,ack in
                let okay = UIAlertAction(title: "Go Back", style: .default) { _ in
                    ClearJoinSessionDetails()
                    self.dismiss(animated: true , completion: nil)
                }
                    
                let alert = Utility().showAlert(hasTextField: false, title: "Session Ended", Msg: "This session has been ended by host.", style: .alert, Actions: [okay])
                DispatchQueue.main.async {
                    self.present(alert, animated: true) {
                        self.tblView.delegate = nil
                        self.tblView.dataSource = nil
                    }
    
                }
            }
        }else{
            
        }

    }
    
    func searchListener(called from :String) {
        print("called from\(from)")
        SocketIOManager.sharedInstance.socket.on("music_search") { [self] Data, ack in
            print(Data)
            var name = ""
            var artistName = ""
            var songId = ""
            var imageURL = ""
            var userdata = NSDictionary()
            var arData: Dictionary = (Data[0] as? Dictionary<String,Any>)!
                        
            if let url:String = arData["image_url"] as? String {
                imageURL = url
            }
            if let id:String = arData["song_title"] as? String {
                songId = id
            }
            if let type:String = arData["artistName"] as? String {
                artistName = type
            }
            if let type:String = arData["name"] as? String {
                name = type
            }
            if let userDetails = arData["user_data"] as? NSDictionary {
                userdata = userDetails
            }
            let username        = userdata.value(forKey:"username")     as! String
            let profileImage    = userdata.value(forKey:"profile_image") as! String
            let displayName     = userdata.value(forKey: "display_name") as! String
            let  addedSong = SongDetails(artistName: artistName, songTitle: songId, songImage: imageURL, name: name, userData: UserData(username: username, displayName: displayName, profileImage: profileImage))
        }
    }
    
}

//MARK: - Extension for Notificaiton
extension Notification.Name {
    static let connectionStatus = Notification.Name("connectionStatus")
    static let reloadTableView = Notification.Name("reloadTable")
    static let reConnect = Notification.Name("reConnect")
}
