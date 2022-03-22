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
import Alamofire
import SDWebImage
import Kingfisher
import SwiftUI


class Singlton {
    static var shared = Singlton()
    var isDeleted = false
}

class RoomPlayListVC: UIViewController, UpdateCurrentSong {
    
    //MARK: - Outlets
    @IBOutlet weak var songPlayingUsersImg: UIImageView!
    @IBOutlet weak var songPlayingUsersName: UILabel!
    @IBOutlet weak var heartBtn: UIButton!
    
    // @IBOutlet weak var Role: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var totalMbmLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    @IBOutlet weak var joinNowBtn: LoadyButton!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var JoinButtonView: UIView!
    @IBOutlet weak var playingSongtitle: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var addsongBtn: UIButton!
    @IBOutlet var nowPlayingImage: [UIImageView]!
    @IBOutlet var nowplayingArtist: [UILabel]!
    @IBOutlet var nowPlayingTitle: [UILabel]!
    
    @IBOutlet var barPlayerView: PlayerView!
    @IBOutlet var bottomBarView: UIView!
    
    @IBOutlet var topMenuBtn: UIBarButtonItem!
    
    //MARK: - Variables
    let subController = SKCloudServiceController()
    var GuestCanPlaySongs = false
    var canExportImport = false
    var AsGuest = false
    var joined = false
    var RoomID = ""
    var roomName = ""
    var invitationCode = ""
    var username = ""
    var userType = ""
    var sessionDetails : Room?
    var fromNotification = false
    var hostUsername = ""
    var playlist : PlayListModel!
    var songArray: [SongDetails] = []
    var AllSongInfo: RequestedSongs?
    var applicationMusicPlayer =  SharedPlayer.shared.appMediaPlayer
    var isLoading = false
    let spinner = UIActivityIndicatorView(style: .medium)
    var fromSessions = false
    var fromprofile = false
    var liked = [likedSong]()
    var likeStatus = [Bool]()
    
    var menuTitle = [String]()
    var menuImages = [String]()
    
    
    ///Variables for Import/export features
    let myPlaylistQuery = MPMediaQuery.playlists()
    var mediaItems = [[MediaItem]]()
    var mediaPlaylist: MPMediaPlaylist!
    let playlistUUIDKey = "playlistUUIDKey"
    
    
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    
    var currentGuestSideSongInfo: SongDetails?
    
    var UpdatePlayer = false
    
    let destruct = UIMenu(title: "More", options: .displayInline, children: [
        UIAction(title: "Delete",image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
            print("Delete tapped")
        }),
    ])
    
    let like = UIMenu(title: "More", options: .displayInline, children: [
        UIAction(title: "Like", image: UIImage(systemName: "heart"), handler: { _ in
            print("Like tapped")
        }),
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barPlayerView.delegate = self
        self.setuptoopmenu()
        barPlayerView.isHidden = true
        bottomBarView.isHidden = true
        
        songPlayingUsersImg.isHidden = true
        songPlayingUsersName.isHidden = true
        heartBtn.isHidden = true
        
        
        self.ClearJoinSessionDetails()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        self.songArray.removeAll()
        fetchSongfromServer()
        let userDefaults = Constants.staticKeys.USER_DEFAULTS
        userDefaults.setValue(self.sessionDetails?.inviteCode, forKey: Constants.staticKeys.invitationCode)
        
        print("====> Room Id", self.RoomID)
        userDefaults.setValue(self.RoomID, forKey: Constants.staticKeys.roomID)
        
        //MARK: - Adding Socket Handlers for music_search listner
        self.searchListener(called :"viewDidLoad/ playlistVC")
        self.onSongDelete()
        self.SessionEndListner()
        self.UpdateNowPlayingListner()
        if fromprofile || fromSessions{
            self.checkRole(isGuest: AsGuest, status: self.sessionDetails!.roomStatus, username: self.sessionDetails!.hostUsername)
        } else if fromNotification{
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            self.checkRole(isGuest: AsGuest, status: "LIVE", username: username)
        }else{
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            self.checkRole(isGuest: AsGuest, status: "LIVE", username: username)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchSongfromServer), name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.updateSocketStatus), name: NSNotification.Name(rawValue: "connectionStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSongtitle), name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.tapAction (_:)))
        //        self.PlayerView.addGestureRecognizer(tapGesture)
        self.userImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.userProfile(_:)))
        self.userImage.addGestureRecognizer(gesture)
        
        if !AsGuest{
            guard let image = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String  else { return }
            let url = Constants.APIUrls.GetImage+image
            self.userImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "person.fill"))
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = "Not Playing"
            }
            self.nowplayingArtist.forEach { arLbl in
                arLbl.text = ""
            }
            self.nowPlayingImage.forEach { imgView in
                imgView.image =  UIImage(named: "NextJamLogo")
                if imgView.tag == 100 {
                    imgView.alpha  = 0.5
                }
            }
        }else {
            if fromSessions{
                guard let RStatus = self.sessionDetails?.roomStatus else { return }
                if RStatus.uppercased() == "LIVE" || RStatus.uppercased() == "ENDED" {
                    
                }else if RStatus.uppercased() == "SCHEDULED"{
                    let status = SocketIOManager.sharedInstance.socket.status
                    guard let session = self.sessionDetails else { return }
                    if status == .connected{
                        self.joinRoom(username: session.hostUsername)
                    }else{
                        SocketIOManager.sharedInstance.establishConnection()
                        sleep(2)
                        self.joinRoom(username: session.hostUsername)
                    }
                }
            }
            guard let image = self.sessionDetails?.hostProfileImage else { return }
            self.userImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(systemName: "person.fill"))
        }
        fetchSongfromServer()
        let imgGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToProfileFromNowPlaying(_:)))
        self.songPlayingUsersImg.addGestureRecognizer(imgGesture)
    }
    
    
    //    MARK: - Below function is for setup of top menu which would be accessible from the navigation bar right button.
    func setuptoopmenu(){
        //handler to intercept event related to UIActions.
        let handler: (_ action: UIAction) -> () = { action in
            print(action.identifier)
            switch action.identifier.rawValue {
            case "Manage_Session":
                self.EndSessionAction()
            case "export":
                self.exportAlert()
            case "import":
                self.importAlert()
            case "invite":
                self.invitaionAction()
            case "attendees":
                self.goToAttendee()
            case "settings":
                self.goToProfile()
            default:
                break
            }
        }
        
        //Initiate an array of UIAction.
        let Hosts = [
            UIAction(title: "Manage Session", identifier: UIAction.Identifier("Manage_Session"), handler: handler),
            UIAction(title: "Export", identifier: UIAction.Identifier("export"), handler: handler),
            UIAction(title: "Import", identifier: UIAction.Identifier("import"), handler: handler),
            UIAction(title: "Invite", identifier: UIAction.Identifier("invite"), handler: handler),
            UIAction(title: "Attendees", identifier: UIAction.Identifier("attendees"), handler: handler),
            UIAction(title: "Settings", identifier: UIAction.Identifier("settings"), handler: handler),
        ]
        let Guests = [
            UIAction(title: "Export", identifier: UIAction.Identifier("export"), handler: handler),
//            UIAction(title: "Import", identifier: UIAction.Identifier("import"), handler: handler),
            UIAction(title: "Attendees", identifier: UIAction.Identifier("attendees"), handler: handler),
            UIAction(title: "Settings", identifier: UIAction.Identifier("settings"), handler: handler),
        ]
        let actions = self.AsGuest ? Guests : Hosts
        let menu = UIMenu(title: "",  children: actions)
        let rightBarButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis.circle")?.withTintColor(UIColor(named: "JAM")!), menu: menu)
        rightBarButton.tintColor = UIColor(named: "JAM")
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func updateCurrentSong() {
        UpdateSongInfoInUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: nil)
    }
    
    override func willMove(toParent parent: UIViewController?){
        super.willMove(toParent: parent)
        if parent == nil {
            if AsGuest{
                if fromprofile || fromSessions {
                    guard let ssn = self.sessionDetails else { return }
                    //    MARK: - Socket event for leaving the current joined room as guest
                    SocketIOManager.sharedInstance.leaveRoomFromSocket(invitationCode: ssn.inviteCode) { status in
                        print(status)
                    }
                }
                //                else{
                //                    if !AsGuest {
                //                        SocketIOManager.sharedInstance.leaveRoomFromSocket(invitationCode: self.invitationCode) { status in
                //                            print(status)
                //                        }
                //                    }
                //                }
            }
            if fromprofile{
                RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) {[self] vc in
                    self.navigationController?.popToViewController(vc, animated: true)
                    ClearJoinSessionDetails()
                }
            }
            if fromNotification{
                RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) {[self] vc in
//                    self.navigationController?.setViewControllers([vc], animated: true)
                    self.navigationController?.popToViewController(vc, animated: true)
                    ClearJoinSessionDetails()
                }
                
                
            }else {
                if self.sessionDetails?.roomStatus == "ENDED" && joined == true{
                    if applicationMusicPlayer?.playbackState == .playing{
                        applicationMusicPlayer?.stop()
                    }
                    self.ClearJoinSessionDetails()
                }else{
                    self.ClearJoinSessionDetails()
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: false)
        
        
        if AsGuest{
                self.title = self.sessionDetails?.roomName
                fetchSongfromServer()
        }
        else {
            if fromprofile{
                self.title = self.sessionDetails?.roomName
                fetchSongfromServer()
            }
            if fromSessions{
                self.title = self.sessionDetails?.roomName
                fetchSongfromServer()
            }else{
                self.title = self.roomName
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UpdateSongInfoInUI()
        setupUI()
    }
    
    
    fileprivate func UpdateSongInfoInUI() {
        if self.songArray.count != 0 {
            
            if SharedPlayer.shared.appMediaPlayer?.nowPlayingItem != nil {
                
                self.nowPlayingImage.forEach { imgView in
                    if let index = SharedPlayer.shared.currentSongIndex {
                        guard let song = SharedPlayer.shared.array else { return }
                        if song.count > index {
                            
                            // loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: SharedPlayer.shared.array?[index].songImage, imageView: imgView)
                            imgView.image = nil
                            
                            imgView.kf.indicatorType = .activity
                            imgView.kf.setImage(with: URL(string: SharedPlayer.shared.currentSongURL), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
                            
                            
                            // loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: SharedPlayer.shared.currentSongURL, imageView: imgView)
                            
                            
                            
                        }
                    }
                }
                
                self.nowPlayingTitle.forEach { lbl in
                    if let index = SharedPlayer.shared.currentSongIndex {
                        guard let song = SharedPlayer.shared.array else { return }
                        if song.count > index {
                            lbl.text = SharedPlayer.shared.array?[index].name
                        }
                    }
                }
                
                self.nowplayingArtist.forEach { arLbl in
                    if let index = SharedPlayer.shared.currentSongIndex {
                        guard let song = SharedPlayer.shared.array else { return }
                        if song.count > index {
                            arLbl.text = SharedPlayer.shared.array?[index].artistName
                        }
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
            self.nowplayingArtist.forEach { arLbl in
                arLbl.text = ""
            }
        }
    }
    
    
    
    //MARK: - Hosting Button Action
    //    @objc func showHostProfile(_ sender: Any) {
    //        let vc = RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen)
    //        let NavigationController = UINavigationController(rootViewController: vc)
    //        NavigationController.modalPresentationStyle = .fullScreen
    //        self.present(NavigationController, animated: true, completion: nil)
    //    }
    
    //MARK: - Update Connection Status
    @objc func updateSocketStatus(sender: NSNotification){
        /*
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
         */
    }
    
    
    //MARK: - Make favorite song button action
    @IBAction func heartBtnAction(_ sender: UIButton) {
        switch AsGuest {
        case true:
            if heartBtn.currentImage == UIImage(systemName: "heart.fill") { // Make Unlike
                nowPlayingUnLikeBtnAction(forHostInfo: nil, forGuestInfo: currentGuestSideSongInfo)
            } else if heartBtn.currentImage == UIImage(systemName: "heart") { // Make Like
                nowPlayingLikeAction(forHostInfo: nil, forGuestInfo: currentGuestSideSongInfo)
            }
        case false:
            if heartBtn.currentImage == UIImage(systemName: "heart.fill") { // Make Unlike
                if let list = SharedPlayer.shared.array, let indx = SharedPlayer.shared.currentSongIndex {
                    let info = list.filter { SongDetails in SongDetails.songTitle == list[indx].songTitle }
                    nowPlayingUnLikeBtnAction(forHostInfo: info, forGuestInfo: nil)
                }
            } else if heartBtn.currentImage == UIImage(systemName: "heart") { // Make Like
                if let list = SharedPlayer.shared.array, let indx = SharedPlayer.shared.currentSongIndex {
                    let info = list.filter { SongDetails in SongDetails.songTitle == list[indx].songTitle }
                    nowPlayingLikeAction(forHostInfo: info, forGuestInfo: nil)
                }
            }
        }
    }
    
    //MARK: - Add Button Action
    @IBAction func addBtnAction(_ sender: UIButton) {
        addSongsAction()
    }
    
    func addSongsAction(){
        let status = SKCloudServiceController.authorizationStatus()
        if status == .authorized{
            moveToSearch(isSearching: true)
        }else{
            SKCloudServiceController.requestAuthorization { [self] (status) in
                if status == .authorized  {
                    moveToSearch(isSearching: true)
                }else{
                    moveToSearch(isSearching: true)
                }
            }
        }
    }
    
    func moveToSearch(isSearching:Bool){
        if isSearching{
            
            RouteCoordinator.NavigateToVC(with: "SearchVC", Controller: "SearchVC", Stroyboard: RouteCoordinator.Main, presentation: .automatic, ofType: SearchVC()) {[self] vc in
                vc.delegate = self
                vc.isSearching = true
                if !self.AsGuest{
                    if fromprofile || fromSessions{
                        guard let ssn = self.sessionDetails else { return }
                        vc.userType = self.userType
                        vc.inviteCode = ssn.inviteCode
                        vc.roomId = ssn.roomID
                    }
                    else{
                        vc.userType = self.userType
                        vc.inviteCode = self.invitationCode
                        vc.roomId = self.RoomID
                    }
                } else{
                        guard let session  = self.sessionDetails else { return }
                        vc.userType = self.userType
                        vc.inviteCode = session.inviteCode
                        vc.roomId = session.roomID
                }
                self.present(vc, animated: true, completion: nil)
            }
            
            
            
        }else{
            
            RouteCoordinator.NavigateToVC(with: "SearchVC", Controller: "SearchVC", Stroyboard: RouteCoordinator.Main, presentation: .automatic, ofType: SearchVC()) { [self] vc in
                vc.delegate = self
                vc.isSearching = false
                if !self.AsGuest{
                    if fromprofile{
                        guard let session  = self.sessionDetails else { return }
                        vc.userType = self.userType
                        vc.inviteCode = session.inviteCode
                        vc.roomId = session.roomID
                    }
                    if fromSessions{
                        guard let session  = self.sessionDetails else { return }
                        vc.userType = self.userType
                        vc.inviteCode = session.inviteCode
                        vc.roomId = session.roomID
                    }else{
                        vc.userType = self.userType
                        vc.inviteCode = self.invitationCode
                        vc.roomId = self.RoomID
                    }
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(msg:String){
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alart = Utility().showAlert(hasTextField: false, title: "Success", Msg: msg, style: .alert, Actions: [ok])
        DispatchQueue.main.async {
            self.JoinButtonView.isHidden = true
            self.PlayerView.isHidden = false
            self.present(alart, animated: true, completion: nil)
        }
    }
    //MARK: - Join Button Action
    @IBAction func joinButtonAction(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else{ return }
        switch title.uppercased() {
        case "START NOW":
            print("Choose an action")
            ///Show alert to start a scheduled a session
            guard let session = self.sessionDetails else { return }
            WebLayerUserAPI().ActivateRoom(roomId: session.roomID) { msg in
                self.showAlert(msg: msg)
            } failure: { err in
                self.showAlert(msg: err.localizedDescription)
            }
            //            let sheet = UIAlertController(title: "Choose an option.", message: "", preferredStyle: .actionSheet)
            //            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //            let startNow = UIAlertAction(title: "Start Now", style: .default) { _ in
            //
            //            }
            //            let addsongs = UIAlertAction(title: "Add Song", style: .default) { [self] _ in
            //                addSongsAction()
            //            }
            //            sheet.addAction(startNow)
            //            sheet.addAction(addsongs)
            //            sheet.addAction(cancel)
            //            DispatchQueue.main.async {
            //                self.present(sheet, animated: true, completion: nil)
            //            }
            break
            
        case "LISTEN MUSIC":
            print("Listen music")
            ///check if user have subsription
            self.checkPermission()
            break
            //        case "START AGAIN":
            //            print("Start Again")
            //            ///show alert to start the party again
            //            guard let session = self.sessionDetails else { return }
            //            WebLayerUserAPI().ActivateRoom(roomId: session.roomID) { msg in
            //                self.showAlert(msg: msg)
            //                self.sessionDetails?.roomStatus = "LIVE"
            //            } failure: { err in
            //                self.showAlert(msg: err.localizedDescription)
            //            }
            //            break
        case "JOIN NOW":
            
            let userDefaults = Constants.staticKeys.USER_DEFAULTS
            guard let username = userDefaults.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            self.joinRoom(username: username)
            break
            
        case "SESSION INFO" :
            let alert = UIAlertController(title: "Session Info", message: "This session is not Started yet. But you can add song to this session.", preferredStyle: .actionSheet)
            let addSong = UIAlertAction(title: "Add Songs", style: .default){ [self] _ in
                addSongsAction()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(addSong)
            alert.addAction(cancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    
    @IBAction func addSongBtnAction(_ sender: UIButton) {
        self.addSongsAction()
    }
    
    //MARK: - Go To User Profile
    @objc func userProfile(_ sender:UITapGestureRecognizer){
        print("======Userprofile Tapped======")
        
        RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) {[self] vc in
            vc.uname = self.nameLB.text!
            guard let img = self.userImage.image else { return }
            vc.image = img
            vc.myprofile = !AsGuest
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func userProfileAction(_ sender: UITapGestureRecognizer) {
        print("did tap image view", sender)
    }
    
    //MARK: - Fetch playlist sogns
    @objc func fetchSongfromServer() {
        var roomid = ""
       
        if fromSessions || fromprofile || fromNotification {
            guard let session = sessionDetails else {
                roomid = self.RoomID
                return }
            roomid = session.roomID
        }else{
            if !AsGuest{
                roomid = self.RoomID
            }
        }
        
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
        print("====> Room Id",roomid)
        
        getLikedSongs()
        WebLayerUserAPI().fetchSongsListFromServer(roomId: roomid) {[self] songslist in
            print("====> Room Id",roomid)
            print("+++++++++++++\(songslist)")
            self.AllSongInfo = songslist
            self.songArray = songslist.songs
            
            //Find for the new song and append them to the application queue
            
            if Singlton.shared.isDeleted == true {
                updateSongWithCurrentPlaying()
                Singlton.shared.isDeleted = false
            }
            setupLikeButton()
            DispatchQueue.main.async { self.tblView.reloadData() }
            //            if self.UpdatePlayer {
            //                guard let ind = SharedPlayer.shared.currentSongIndex else { return }
            //                self.playSong(for: ind, update: true)
            //            }
            SharedPlayer.shared.array = []
            SharedPlayer.shared.array = songslist.songs
            //            if !self.UpdatePlayer{
            //
            //            }
            
        } failure: { Error in
            print("+++++++++++++\(Error)")
            print(Error)
        }
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: nil)
    }
    
    //MARK: - Get the liked song for the user and setup the like button for the playlist songs
    
    func getLikedSongs() {
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else {return}
        WebLayerUserAPI().fetchUserLikedSongs(username: username) { data in
            self.liked = data
            self.setupLikeButton()
        } failure: { error in
            print(error)
        }
    }
    
    //MARK: - Method to update the like buttons
    func setupLikeButton(){
        let plCount = self.songArray.count
        var tempLikes = [Bool]()
        for i in 0..<plCount{
            let pltitle = self.songArray[i].songTitle
            if self.liked.contains(where: {$0.songTitle == pltitle}){
                tempLikes.insert(true, at: i)
            }else{
                tempLikes.insert(false, at: i)
            }
        }
        self.likeStatus = tempLikes
        print("============>\n\(self.likeStatus)\n<=============")
    }
    
    //MARK: - To check is song is liked or not
    func checkLiked(id:String)->String{
        var image = "heart"
        let liked = self.liked
        if liked.contains(where: { $0.songTitle == id}){
            image = "heart.fill"
        }
        return image
    }
    
    // MARK: - lLike button action for api call
    @objc func likeAction(sender: Int) {
        
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{ return }
        
        if !self.likeStatus[sender]{
            let params = ["artist_name":self.songArray[sender].artistName,
                          "song_title":self.songArray[sender].songTitle,
                          "image_url":self.songArray[sender].songImage,
                          "name":self.songArray[sender].name ]
            
            
            WebLayerUserAPI().LikeSongs(params: params, username: username) { data in
                print("================\nSong liked\n=================")
                self.fetchSongfromServer()
                //                self.setupLikeButton()
                
            } failure: { error in
                print(error)
            }
        }else {
            
            WebLayerUserAPI().unlikeSong(with: Int(self.songArray[sender].songTitle)!, username: username) { data in
                print("===============\n\(data)\n============")
                self.fetchSongfromServer()
                //                self.setupLikeButton()
                
            } failure: { error in
                print(error)
            }
        }
    }
    
    func removeFromSharedArray(songID:String){
        guard let arr = SharedPlayer.shared.array else { return }
        for i in 0..<arr.count{
            if arr[i].songTitle == songID {
                SharedPlayer.shared.array?.remove(at: i)
            }
        }
    }
    //MARK: - Delete song from the playlist
    @objc func deleteAction(sender : Int){
        let songId = self.songArray[sender].songTitle
        var roomId = ""
        
        if fromSessions || fromprofile {
            guard let ssn = sessionDetails else { return }
            roomId = ssn.roomID
        }else{
            roomId = self.RoomID
        }
        WebLayerUserAPI().deleteSomgfromPlaylist(with: roomId, with: songId) { response in
            Singlton.shared.isDeleted = true
            self.fetchSongfromServer()
            self.setupLikeButton()
            self.removeFromSharedArray(songID: songId)
            self.NotifyforSongDeletion(songid:songId)
        } failure: { error in
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Error", Msg: error.localizedDescription, style: .alert, Actions: [ok])
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func NotifyforSongDeletion(songid:String){
        var id = String()
        if fromprofile || fromSessions || fromNotification {
            guard let ssn = self.sessionDetails else { return }
            id = ssn.inviteCode
        }else {
            if !AsGuest{
                id = self.invitationCode
            }
        }
        SocketIOManager.sharedInstance.notifyForSongDeletion(invitationCode: id)
        let q = DispatchQueue.main
        q.async {
            
            //    MARK: - Below code is to update the current playing queue by removing the deleted song by host after firing the socket event "delete_song" for notifying other users in the room and to update playlist on their end.
            SharedPlayer.shared.appMediaPlayer?.perform(queueTransaction: { queue in
                var i = MPMediaItem()
                for itm in queue.items{
                    if itm.playbackStoreID == songid{
                        i = itm
                    }
                }
                return queue.remove(i)
            }, completionHandler: { cq, err in
                if err != nil {
                    print("error in removing from queque",err?.localizedDescription)
                    //                    fetchSongfromServer()
                } else{
                    //                    fetchSongfromServer()
                    print("Song removed from queue successfully.")
                }
            })
        }
        
    }
}

//MARK: - RoomPlayListVC Private Extension Navigation Buttons
private extension RoomPlayListVC {
    
    //MARK: - Invitation action for menu button
    @objc func invitaionAction(){
        RouteCoordinator.NavigateToVC(with: "InvitationVC", Controller: "InvitationVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: InvitationVC()) {[self] vc in
            vc.fromparty = false
            if fromSessions || fromprofile {
                guard let ssn = sessionDetails else {return }
                vc.roomID = ssn.roomID
            }else{
                vc.roomID = self.RoomID
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: - Import playlist action alert
    @objc func importAlert() {
        let alert = UIAlertController(title: "Import from Apple Music", message: "Do you want to import a playlist from Apple Music?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let Import = UIAlertAction(title: "Import", style: .default) { _ in
            self.checkSubscription()
            if self.canExportImport {
                self.moveToSearch(isSearching:false)
            }
        }
        alert.addAction(cancel)
        alert.addAction(Import)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Import playlist action
    func importPlaylist(){
        let playlists = myPlaylistQuery.collections
        for playlist in playlists! {
            print("================>\n")
            print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
            print("\n<================")
            let songs = playlist.items
            for song in songs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
                print("\t\t", songTitle!)
            }
        }
        
        RouteCoordinator.NavigateToVC(with: "SearchVC", Controller: "SearchVC", Stroyboard: RouteCoordinator.Room, presentation: .automatic, ofType: SearchVC()) { vc in
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    //MARK: - Export playlist action alert
    @objc func exportAlert() {
        let alert = UIAlertController(title: "Export to Apple Music", message: "Do you want to export this playlist to Apple Music?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let export = UIAlertAction(title: "Export", style: .default) { _ in
            self.checkSubscription()
            if self.canExportImport {
                self.ExportPlaylist()
            }
        }
        alert.addAction(cancel)
        alert.addAction(export)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Export playlist action
    func ExportPlaylist(){
        guard mediaPlaylist == nil else { return }
        let playlistUUID: UUID
        var playlistCreationMetadata: MPMediaPlaylistCreationMetadata!
        let userDefaults = UserDefaults.standard
        playlistUUID = UUID()
        playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: self.title!)
        playlistCreationMetadata.descriptionText = "This playlist was exported from \(Bundle.main.infoDictionary!["CFBundleName"]!)."
        userDefaults.setValue(playlistUUID.uuidString, forKey: playlistUUIDKey)
        userDefaults.synchronize()
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
            guard error == nil else {
                fatalError("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
            }
            self.songArray.forEach { song in
                playlist?.addItem(withProductID: song.songTitle, completionHandler: { _ in
                })
            }
            let alert = UIAlertController(title: "Success", message: "Your playlist exported successfully.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(_ sender : UIButton){
        if fromNotification{
            RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                self.navigationController?.setViewControllers([vc], animated: true)
                self.ClearJoinSessionDetails()
            }
        } else {
            self.dismiss(animated: true) { [self] in
                if self.sessionDetails?.roomStatus == "ENDED" && joined == true{
                    if applicationMusicPlayer?.playbackState == .playing{
                        applicationMusicPlayer?.stop()
                    }
                    self.ClearJoinSessionDetails()
                }else{
                    self.ClearJoinSessionDetails()
                }
            }
        }
    }
    
    
    //MARK: - Clear Session Details
    func ClearJoinSessionDetails() {
        Constants.staticKeys.USER_DEFAULTS.removeObject(forKey: Constants.staticKeys.invitationCode)
        Constants.staticKeys.USER_DEFAULTS.removeObject(forKey:Constants.staticKeys.roomName)
        Constants.staticKeys.USER_DEFAULTS.removeObject(forKey:Constants.staticKeys.roomID)
        
        SharedPlayer.shared.appMediaPlayer?.pause()
        SharedPlayer.shared.appMediaPlayer?.stop()
        SharedPlayer.shared.timer?.invalidate()
        SharedPlayer.shared.isPaused = true
        
        SharedPlayer.shared.array?.removeAll()
        SharedPlayer.shared.appMediaPlayer = nil
        SharedPlayer.shared.timer = nil
        UserDefaults.standard.removeObject(forKey: "PlaybackDuration")
    }
    
}

//MARK: - UI Functions
extension RoomPlayListVC {
    
    //MARK: - Check Role Action
    func checkRole(isGuest: Bool,status:String,username:String){
        self.addsongBtn.isHidden = true
        switch status.uppercased() {
        case "LIVE":
            print(#function)
            print("inside LIVE case")
            if isGuest{
                self.JoinButtonView.isHidden = joined
            }else{
                self.JoinButtonView.isHidden = true
                self.PlayerView.isHidden = false
                /*
                 barPlayerView.isHidden = false
                 bottomBarView.isHidden = false
                 */
                if !joined{
                    self.joinRoom(username: username)
                }
            }
            break
        case "ENDED":
            print(#function)
            print("inside ENDEd case")
            if !joined {
                self.JoinButtonView.isHidden = false
            }
            if isGuest{
                self.joinNowBtn.setTitle("Listen Music", for: .normal)
            }else{
                self.joinNowBtn.setTitle("Listen Music", for: .normal)
                
            }
            break
            
        case "SCHEDULED":
            print(#function)
            print("inside Schedule case")
            if !joined {
                self.JoinButtonView.isHidden = false
            }else{
                self.JoinButtonView.isHidden = true
                self.PlayerView.isHidden = false
                
                barPlayerView.isHidden = false
                bottomBarView.isHidden = false
            }
            
            if isGuest{
                self.joinNowBtn.setTitle("Join Now", for: .normal)
                //                self.joinNowBtn.tag = 100
            }else{
                self.joinNowBtn.setTitle("Start Now", for: .normal)
                self.addsongBtn.isHidden = false
            }
            
            break
        default:
            break
        }
    }
    
    //MARK: - Setup ViewController UI
    func setupUI(){
        if AsGuest{
            self.nameLB.text = self.sessionDetails?.hostUsername.lowercased()
        }else {
            guard let image = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.imageUrl) as? String else { return }
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            guard let displayName = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.DisplayName) as? String else { return }
            if self.GuestCanPlaySongs == true {
                self.nameLB.text = self.sessionDetails?.hostUsername.lowercased()
            }else{
                self.nameLB.text = username.lowercased()
            }
            
            // self.Role.text = "\(displayName)".capitalized
        }
        
        self.addsongBtn.MakeRound()
        self.userImage.MakeRound()
        self.userImage.layer.borderWidth = 2
        self.userImage.layer.borderColor = #colorLiteral(red: 0.5985194445, green: 0.1699213684, blue: 0.3734838367, alpha: 1)
        
        self.songPlayingUsersImg.MakeRound()
        self.songPlayingUsersImg.layer.borderWidth = 2
        self.songPlayingUsersImg.layer.borderColor = #colorLiteral(red: 0.5985194445, green: 0.1699213684, blue: 0.3734838367, alpha: 1)
        
        self.joinNowBtn.MakeRound()
    }
    
    //MARK: - Update Now Playing Label on changes
    @objc func updateSongtitle() {
        self.nowPlayingTitle.forEach { lbl in
            lbl.text = self.applicationMusicPlayer?.nowPlayingItem?.title
        }
        self.nowplayingArtist.forEach { arLbl in
            arLbl.text = self.applicationMusicPlayer?.nowPlayingItem?.artist
        }
        self.nowPlayingImage.forEach { imgView in
            imgView.image =  self.applicationMusicPlayer?.nowPlayingItem?.artwork?.image(at: CGSize(width: imgView.frame.width, height: imgView.frame.height)) ?? UIImage(named: "NextJamLogo")
        }
    }
}

//MARK: - Searhc VC Protocol To get songs
extension RoomPlayListVC: SearchVCProtocol {
    func getSongListDelegateMethod(isSearching: Bool) {
        self.UpdatePlayer = true
        
        fetchSongfromServer()
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    
    
    
    func updateSongWithCurrentPlaying() {
        //        SharedPlayer.shared.appMediaPlayer?.perform(queueTransaction: { qu in
        //            qu.remove(<#T##item: MPMediaItem##MPMediaItem#>)
        //        }, completionHandler: { <#MPMusicPlayerControllerQueue#>, <#Error?#> in
        //            <#code#>
        //        })
        
        //        var isCheckCurrentSongStatus = false
        //
        //        if SharedPlayer.shared.appMediaPlayer?.playbackState == .playing {
        //            isCheckCurrentSongStatus = true
        //        }
        //
        //        var SongId: [String] = []
        //        SharedPlayer.shared.array?.forEach({ s in
        //            SongId.append(s.songTitle)
        //        })
        //
        ////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //            let catalogQueue = MPMusicPlayerStoreQueueDescriptor(storeIDs: SongId)
        //            if let SId = SharedPlayer.shared.currentSongId,
        //                let playbackDuration = UserDefaults.standard.value(forKey: "PlaybackDuration") as? Int64 {
        //                catalogQueue.startItemID = SId
        //                catalogQueue.setStartTime(TimeInterval(playbackDuration), forItemWithStoreID: SId)
        //            }
        //            SharedPlayer.shared.appMediaPlayer?.setQueue(with: catalogQueue)
        //            SharedPlayer.shared.appMediaPlayer?.prepareToPlay { (error) in
        //                if (error != nil) {
        //                    print("[MUSIC PLAYER] Error preparing : \(String(describing: error))")
        //                } else {
        //                    if isCheckCurrentSongStatus {
        //                        SharedPlayer.shared.isPaused = false
        //                        SharedPlayer.shared.appMediaPlayer?.play()
        //                    }
        //                }
        //            }
        //            UserDefaults.standard.removeObject(forKey: "PlaybackDuration")
        ////        }
        
        
    }
    
    
}

//MARK: - Playlist Table View Delegate & DataSource
extension RoomPlayListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var row = 0
        
        switch AsGuest {
        case true:
            row = self.songArray.count
        case false:
            row = self.songArray.count
        }
        
        return row
        
    }
    
    @objc func goToProfileFromNowPlaying(_ gesture: UITapGestureRecognizer){
        var profileStatus = Bool()
        if let index = SharedPlayer.shared.currentSongIndex {
            RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { vc in
                guard let song = SharedPlayer.shared.array else { return }
                guard let cell = self.tblView.cellForRow(at: IndexPath(row: index, section: 0)) as? RoomPlayListCell else { return }
                vc.uname = self.songArray[index].userData.username
                vc.image = cell.UserAddingSngImg.image!
                guard let usrnm = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                if usrnm == self.songArray[index].userData.username {
                    profileStatus = true
                }else {
                    profileStatus = false
                }
                vc.myprofile = profileStatus
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
        
        print("inside the now playing gesture method")
    }
    
    @objc func userprofileAction(_ gesture:UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.tblView)
        var profileStatus = Bool()
        if let tappedIndexPath = self.tblView.indexPathForRow(at: tapLocation){
            
            RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { vc in
                vc.uname = self.songArray[tappedIndexPath.row].userData.username
                guard let cell = self.tblView.cellForRow(at: tappedIndexPath) as? RoomPlayListCell else { return }
                vc.image = cell.UserAddingSngImg.image!
                
                guard let usrnm = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                if usrnm == self.songArray[tappedIndexPath.row].userData.username {
                    profileStatus = true
                }else {
                    profileStatus = false
                }
                vc.myprofile = profileStatus
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            print("on the user image")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        guard let c = tableView.dequeueReusableCell(withIdentifier: "RoomPlayListCell") as? RoomPlayListCell else { return UITableViewCell.init() }
        c.UserAddingSngImg.MakeRound()
        c.albumImage.layer.borderColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        c.albumImage.layer.borderWidth = 2
        c.songTitle.text  = self.songArray[indexPath.row].name
        c.artistName.text = self.songArray[indexPath.row].artistName
        c.userAddingSngName.text = self.songArray[indexPath.row].userData.username
        if self.songArray.count != 0 {
            
            c.albumImage.kf.indicatorType = .activity
            c.albumImage.kf.setImage(with: URL(string: self.songArray[indexPath.row].songImage), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
            
            c.UserAddingSngImg.kf.indicatorType = .activity
            c.UserAddingSngImg.kf.setImage(with: URL(string: self.songArray[indexPath.row].userData.profileImage), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
            
            // c.albumImage.sd_setImage(with: URL(string: self.songArray[indexPath.row].songImage), placeholderImage: UIImage(systemName: "person.fill"))
            // c.UserAddingSngImg.sd_setImage(with: URL(string: self.songArray[indexPath.row].userData.profileImage), placeholderImage: UIImage(systemName: "person.fill"))
            
        }
        c.dltBtn.isHidden = self.sessionDetails?.roomStatus == "ENDED" ? true :  false
        c.selectionStyle = .none
        c.dltBtn.isHidden = false
        c.dltBtn.tag = indexPath.row
        c.dltBtn.showsMenuAsPrimaryAction = true
        c.dltBtn.menu = self.setupMenu(index: indexPath, isGuest:AsGuest)
        c.UserAddingSngImg.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.userprofileAction(_:)))
        c.UserAddingSngImg.addGestureRecognizer(gesture)
        cell = c
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 100{
            if !AsGuest {
                self.playSong(for: indexPath.row,update:false)
            } else if (AsGuest && GuestCanPlaySongs) {
                guard let session = self.sessionDetails else { return }
                if session.roomStatus.uppercased() == "ENDED"{
                    self.playSong(for: indexPath.row,update:false)
                }
            }
        }
    }
    
    // MARK: - Setup menu for tableView Cell
    func setupMenu(index:IndexPath,isGuest:Bool)->UIMenu {
        let destruct = UIAction(title: "Delete",image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            
            print("song title======>",self.songArray[index.row].songTitle)
            print("song title/id======>",self.applicationMusicPlayer?.nowPlayingItem?.playbackStoreID)
            guard let state = self.applicationMusicPlayer?.playbackState else { return }
            if state == .playing || state == .paused {
                guard let playingID = self.applicationMusicPlayer?.nowPlayingItem?.playbackStoreID else { return }
                if self.songArray[index.row].songTitle == playingID {
                    let alert = UIAlertController(title: "Couldn't delete!", message: "You can not delete the current playing song.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self.UpdateSongInfoInUI()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.deleteAction(sender: index.row)
                }
            }else{
                self.deleteAction(sender: index.row)
            }
        }
        
        let status = self.likeStatus[index.row]
        let items = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: status ? "Unlike":"Like", image: UIImage(systemName: status ? "heart.fill":"heart"), handler: { _ in
                self.likeAction(sender:index.row)
                self.likeStatus[index.row] = !status
                self.tblView.reloadData()
            })
        ])
        let menu = isGuest ?  UIMenu(title: "", children: [items]) :UIMenu(title: "", children: [items, destruct])
        return menu
    }
    
    //MARK: - Go to the Attendee Controller
    func goToAttendee(){
        var roomID = ""
        if AsGuest{
            if fromNotification {
                roomID = self.RoomID
            }else{
                guard let ssn = self.sessionDetails else { return }
                roomID = ssn.roomID
            }
        }else{
            if fromSessions || fromprofile{
                guard let ssn = self.sessionDetails else { return }
                roomID = ssn.roomID
            }else{
                roomID = self.RoomID
            }
        }
        
        RouteCoordinator.NavigateToVC(with: "AttendeesViewController", Controller: "AttendeesViewController", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: AttendeesViewController()) { vc in
            vc.roomId = roomID
            vc.fromProfile = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: - Go to Profile Controller
    func goToProfile() {
        RouteCoordinator.NavigateToVC(with: "SettingsVC", Controller: "SettingsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: SettingsVC()) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - Play Tapped song
    func playSong(for indexPath: Int, update:Bool){
        
        DispatchQueue.main.async {
            self.nowPlayingImage.forEach { imgView in
                imgView.image = nil
                let img = SharedPlayer.shared.appMediaPlayer?.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400))
                imgView.image = img
            }
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = SharedPlayer.shared.appMediaPlayer?.nowPlayingItem?.title ?? ""
            }
            self.nowplayingArtist.forEach { arLbl in
                arLbl.text = SharedPlayer.shared.appMediaPlayer?.nowPlayingItem?.artist ?? "" //self.songArray[indexPath].artistName
            }
        }
        
        //        let vc = RouteCoordinator.NavigateToVC(with: "PlayerViewController", Controller: "PlayerViewController", Stroyboard: RouteCoordinator.Player, presentation: .fullScreen) as! PlayerViewController
        //        vc.isComeFrom = "PlaySong"
        
        
        /*
         SharedPlayer.shared.timer?.invalidate()
         SharedPlayer.shared.appMediaPlayer.pause()
         SharedPlayer.shared.isPaused = true
         SharedPlayer.shared.array = []
         SharedPlayer.shared.appMediaPlayer.nowPlayingItem = nil
         */
        DispatchQueue.main.async { [self] in
            if !update{
                
                self.ClearJoinSessionDetails()
                SharedPlayer.shared.currentSongIndex = indexPath
                if fromSessions || fromprofile{
                    guard let ssn = sessionDetails else{ return }
                    let iC = ssn.inviteCode
                    SharedPlayer.shared.appMediaPlayer?.currentPlaybackTime = 0
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }else if fromNotification {
                    let iC = self.invitationCode
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }else{
                    let iC = self.invitationCode
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }
                
                //        vc.delegate = self
                
                SharedPlayer.shared.playOne = false
                SharedPlayer.shared.initilize()
                
                barPlayerView.isHidden = false
                bottomBarView.isHidden = false
                
                setCurrentPlayingSongInfo()
            }
            else{
                
                SharedPlayer.shared.currentSongIndex = SharedPlayer.shared.appMediaPlayer?.indexOfNowPlayingItem
                if self.fromSessions || self.fromprofile{
                    guard let ssn = self.sessionDetails else{ return }
                    let iC = ssn.inviteCode
                    guard let time = SharedPlayer.shared.appMediaPlayer else { return }
                    SharedPlayer.shared.appMediaPlayer?.currentPlaybackTime = time.currentPlaybackTime
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }else if fromNotification{
                    let iC = self.invitationCode
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }else{
                    let iC = self.invitationCode
                    SharedPlayer.shared.invitation = iC
                    SharedPlayer.shared.array = self.songArray
                }
                //                SharedPlayer.shared.appMediaPlayer?.play()
                SharedPlayer.shared.playOne = true
                //                SharedPlayer.shared.initilize(reinitialise: true)
                
                self.barPlayerView.isHidden = false
                self.bottomBarView.isHidden = false
            }
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

//MARK: - Socket Events
extension RoomPlayListVC{
    
    //MARK: - Listener decleration to update the current playing song when host changes or next song is played
    func UpdateNowPlayingListner() {
        SocketIOManager.sharedInstance.socket.on("update_currently_playing") { [self]
            data, ack in
            
            print("Current Playing song-----")
            print(data)
            guard let nowPlaying = (data[0] as? Dictionary<String,Any>)!["song_name"] as? String else { return }
            guard let nowPlayingID = (data[0] as? Dictionary<String,Any>)!["song_title"] as? String else { return }
            
            //            guard let playinArtist = (data[0] as? Dictionary<String,Any>)!["artist_name"] as? String else { return }
            print("updated Song Name =>",nowPlaying)
            self.nowPlayingTitle.forEach { lbl in
                lbl.text = nowPlaying
            }
            
            self.nowPlayingImage.forEach { imgView in
                self.songArray.forEach { song in
                    
                    if song.songTitle == nowPlayingID {
                        currentGuestSideSongInfo = song
                        
                        self.nowplayingArtist.forEach { arLbl in
                            arLbl.text = song.artistName
                        }
                        imgView.image = nil
                        // loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: song.songImage, imageView: imgView)
                        
                        imgView.kf.indicatorType = .activity
                        imgView.kf.setImage(with: URL(string: song.songImage), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
                        
                        setCurrentPlayingSongInfoGuestSide(information: song)
                    }
                }
            }
        }
    }
    
    //MARK: - Listener decleration to update the playlist when guest/ host added song to the playlist
    func searchListener(called from :String) {
        print("called from\(from)")
        SocketIOManager.sharedInstance.socket.on("music_search") { [self] Data, ack in
            print(Data)
            guard let err = (Data[0] as! NSDictionary).value(forKey: "error") as? String else {
                Singlton.shared.isDeleted = true
                guard let songId = (Data[0] as? NSDictionary)?.value(forKey: "song_title") as? String else { return }
                guard let state = SharedPlayer.shared.appMediaPlayer?.playbackState else{
                    fetchSongfromServer()
                    return
                }
                if state == .playing {
                    self.UpdatePlayer = true
                    let q = DispatchQueue.main
                    q.async {
                        //    MARK: - below code is for performing queuue transaction to updating the current queue by adding the songs after the last item of the queue.
                        
                        SharedPlayer.shared.appMediaPlayer?.perform(queueTransaction: { queue in
                            let afterItem = queue.items.last
                            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [songId])
                            return queue.insert(descriptor, after: afterItem)
                        }, completionHandler: { cq, err in
                            if err != nil {
                                print("error in adding song to the queue",err)
                                fetchSongfromServer()
                            } else{
                                fetchSongfromServer()
                                print(Data[0])
                                print("Song added to queue successfully.")
                            }
                        })
                    }
                }
                return
            }
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let errorAlert = Utility().showAlert(hasTextField: false, title: "Error", Msg: err.uppercased(), style: .alert, Actions: [ok])
            
            if let currentVC = UIApplication.topViewController() as? SearchVC {
                currentVC.present(errorAlert, animated: true, completion: nil)
            }
            //            var name = ""
            //            var artistName = ""
            //            var songId = ""
            //            var imageURL = ""
            //            var userdata = NSDictionary()
            //            var arData: Dictionary = (Data[0] as? Dictionary<String,Any>)!
            //
            //            if let url:String = arData["image_url"] as? String {
            //                imageURL = url
            //            }
            //            if let id:String = arData["song_title"] as? String {
            //                songId = id
            //            }
            //            if let type:String = arData["artistName"] as? String {
            //                artistName = type
            //            }
            //            if let type:String = arData["name"] as? String {
            //                name = type
            //            }
            //            if let userDetails = arData["user_data"] as? NSDictionary {
            //                userdata = userDetails
            //            }
            //            let username        = userdata.value(forKey:"username")     as! String
            //            let profileImage    = userdata.value(forKey:"profile_image") as! String
            //            let displayName     = userdata.value(forKey: "display_name") as! String
            //            let  addedSong = SongDetails(artistName: artistName, songTitle: songId, songImage: imageURL, name: name, userData: UserData(username: username, displayName: displayName, profileImage: profileImage))
        }
    }
    func onSongDelete(){
        SocketIOManager.sharedInstance.socket.on("delete_song") { data, ack in
            print(data[0])
            guard let isDeleted = data[0] as? NSDictionary else { return }
            if isDeleted.value(forKey: "deleted") as! Bool {
                self.fetchSongfromServer()
            }
        }
    }
    
    //MARK: - New Memeber joined Event listner
    func onNewMemberJoinListner(){
        SocketIOManager.sharedInstance.socket.on("new_member") {[self] data, ack in
            
            
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            joined = true
            if AsGuest {
                
                print(self.AllSongInfo?.currentlyPlaying)
                
                self.nowPlayingTitle.forEach { lbl in
                    lbl.text = self.AllSongInfo?.currentlyPlaying?.name
                }
                self.nowplayingArtist.forEach { arLbl in
                    arLbl.text = self.AllSongInfo?.currentlyPlaying?.artistName
                }
                self.nowPlayingImage.forEach { imgView in
                    if let img = self.AllSongInfo?.currentlyPlaying?.songImage {
                        
                        imgView.kf.indicatorType = .activity
                        imgView.kf.setImage(with: URL(string: img), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
                    }
                }
                if fromNotification{
                    checkRole(isGuest: AsGuest, status: "LIVE", username: username)
                }else{
                    checkRole(isGuest: AsGuest, status: sessionDetails!.roomStatus, username: username)
                }
            }else{
                if fromSessions || fromprofile {
                    checkRole(isGuest: AsGuest, status: sessionDetails!.roomStatus, username: username)
                }else{
                    checkRole(isGuest: AsGuest, status: "LIVE", username: username)
                }
            }
        }
    }
    
    //    MARK: - Leave Room Event
    func leaveRoom(){
        let IC = (fromprofile || fromSessions && !fromNotification ? self.sessionDetails?.inviteCode : self.invitationCode)!
        SocketIOManager.sharedInstance.leaveRoomFromSocket(invitationCode: IC) { status in
            print("leave room",status)
        }
    }
    
    //MARK: - Join Room Action
    func joinRoom(username:String){
        if fromNotification{
            let userDefaults = Constants.staticKeys.USER_DEFAULTS
            userDefaults.set(self.invitationCode, forKey: Constants.staticKeys.invitationCode)
            userDefaults.set(self.roomName, forKey: Constants.staticKeys.roomName)
            userDefaults.set(self.RoomID, forKey: Constants.staticKeys.roomID)
            let status = SocketIOManager.sharedInstance.socket.status
            if status == .connected {
                SocketIOManager.sharedInstance.connectToServerWithNickName(nickName: username, inviteCode: self.invitationCode) { list in
                    print(list)
                }
                onNewMemberJoinListner()
                Constants.staticKeys.USER_DEFAULTS.set(self.invitationCode, forKey: Constants.staticKeys.invitationCode)
            }else{
                SocketIOManager.sharedInstance.establishConnection()
            }
        }else{
            let userDefaults = Constants.staticKeys.USER_DEFAULTS
            guard let sessionInfo = self.sessionDetails else { return }
            userDefaults.set(sessionInfo.inviteCode, forKey: Constants.staticKeys.invitationCode)
            userDefaults.set(sessionInfo.roomName, forKey: Constants.staticKeys.roomName)
            userDefaults.set(sessionInfo.roomID, forKey: Constants.staticKeys.roomID)
            let status = SocketIOManager.sharedInstance.socket.status
            if status == .connected {
                SocketIOManager.sharedInstance.connectToServerWithNickName(nickName: username, inviteCode: sessionInfo.inviteCode) { list in
                    print(list)
                }
                onNewMemberJoinListner()
                Constants.staticKeys.USER_DEFAULTS.set(sessionInfo.inviteCode, forKey: Constants.staticKeys.invitationCode)
            }else{
                SocketIOManager.sharedInstance.establishConnection()
            }
        }
    }
    
    //MARK: -End Session Action
    @objc func EndSessionAction(){
        
        let Delete = UIAlertAction(title: "Delete Session", style: .destructive){ _ in
            if self.fromSessions || self.fromprofile {
                //MARK: - Exit from Session
                self.tblView.delegate = nil
                self.tblView.dataSource = nil
                guard let rId = self.sessionDetails?.roomID as? String else { return }
                
                guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                WebLayerUserAPI().DeleteRoom(for: username, with: rId) { del in
                    //                    status = (del,"Room deleted successfully")
                    //MARK: - End CurrentSession
                    DispatchQueue.main.async{
                        self.ClearJoinSessionDetails()
                        self.leaveRoom()
                        self.dismiss(animated: true) {
                            JamSessionVC().segmentIndex = 2
                        }
                    }
                } failure: { error in
                    //                    status = (false,error)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
                
                //MARK: - Exit from Session
                self.tblView.delegate = nil
                self.tblView.dataSource = nil
                
                var rId =  ""
                if self.fromprofile || self.fromSessions {
                    guard let ssn = self.sessionDetails else { return }
                    rId = ssn.roomID
                }else {
                    rId = self.RoomID
                }
                guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                WebLayerUserAPI().DeleteRoom(for: username, with: rId) { del in
                    //                    status = (del,"Room deleted successfully")
                    //MARK: - End CurrentSession
                    DispatchQueue.main.async{
                        SocketIOManager.sharedInstance.exitFromSocketWithNickName(nickname: Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String, roomid: rId ) {
                            print("exitted from the room")
                        }
                        self.ClearJoinSessionDetails()
                        self.leaveRoom()
                        self.dismiss(animated: true) {}
                    }
                } failure: { error in
                    //                    status = (false,error)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
        }
        let End = UIAlertAction(title: "End session", style: .default) { _ in
            
            if self.fromSessions || self.fromprofile {
                //MARK: - Exit from Session
                self.tblView.delegate = nil
                self.tblView.dataSource = nil
                guard let rId = self.sessionDetails?.roomID else { return }
                
                SocketIOManager.sharedInstance.exitFromSocketWithNickName(nickname: Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String, roomid: rId ) {
                    print("exitted from the room")
                }
                //MARK: - End CurrentSession
                
                self.ClearJoinSessionDetails()
                self.leaveRoom()
                self.dismiss(animated: true) {}
                
            }else{
                
                //MARK: - Exit from Session
                self.tblView.delegate = nil
                self.tblView.dataSource = nil
                
                var rId =  ""
                if self.fromprofile || self.fromSessions {
                    guard let ssn = self.sessionDetails else { return }
                    rId = ssn.roomID
                }else {
                    rId = self.RoomID
                }
                
                SocketIOManager.sharedInstance.exitFromSocketWithNickName(nickname: Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String, roomid:rId) {
                    print("exitted from the room")
                }
                
                self.ClearJoinSessionDetails()
                self.leaveRoom()
                RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                    let navigation = UINavigationController(rootViewController: vc)
                    navigation.modalPresentationStyle = .fullScreen
                    //                self.navigationController?.popToViewController(navigation, animated: true)
                    self.present(navigation, animated: true, completion: nil)
                }
            }
            
        }
        let leave = UIAlertAction(title: "Leave", style: .default){_ in
         
            self.applicationMusicPlayer?.stop()
            self.ClearJoinSessionDetails()
            if self.fromprofile{
                self.dismiss(animated: true) {
                    self.applicationMusicPlayer?.stop()
                    self.ClearJoinSessionDetails()
                    self.leaveRoom()
                }
            }else {
                RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { vc in
                    let navigation = UINavigationController(rootViewController: vc)
                    navigation.modalPresentationStyle = .fullScreen
                    //                self.navigationController?.popToViewController(navigation, animated: true)
                    self.present(navigation, animated: true, completion: nil)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if self.sessionDetails?.roomStatus == "ENDED"{
            DispatchQueue.main.async {
                self.present(Utility().showAlert(hasTextField: false, title: "Manage Session", Msg: "Choose an option.", style: .alert, Actions:[Delete,leave,cancel]), animated: true, completion: nil)
            }
        }else{
            DispatchQueue.main.async {
                self.present(Utility().showAlert(hasTextField: false, title: "Manage Session", Msg: "Choose an option.", style: .alert, Actions:[Delete, End,leave,cancel] ), animated: true, completion: nil)
            }
        }
        
    }
    
    //MARK: - Listener for end session event and to get the user out of the sessio
    func SessionEndListner(){
        if AsGuest{
            SocketIOManager.sharedInstance.socket.on("close_room") {[self] data,ack in
                let okay = UIAlertAction(title: "Go Back", style: .default) { _ in
                    ClearJoinSessionDetails()
                    self.navigationController?.popViewController(animated: true)
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
    
}

//MARK: - Check Subscriptions and present controller to buy.
extension RoomPlayListVC : SKCloudServiceSetupViewControllerDelegate{
    
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
            //
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
                DispatchQueue.main.async {
                    self.canExportImport = true
                    self.GuestCanPlaySongs = true
                    self.addsongBtn.isHidden = true
                    self.JoinButtonView.isHidden = true
                    self.AsGuest = false
                    guard let image = self.sessionDetails?.hostProfileImage as? String  else { return }
                    let url = image
                    self.userImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "person.fill"))
                    self.nameLB.text = self.sessionDetails?.hostUsername.lowercased()
                }
            }else if capabilities.contains(.musicCatalogSubscriptionEligible) && !capabilities.contains(.musicCatalogPlayback){
                print("doesn't have subscription")
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
    
    //MARK: -Load Image
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



//MARK: - Extension for Notificaiton
extension Notification.Name {
    static let connectionStatus = Notification.Name("connectionStatus")
    static let reloadTableView = Notification.Name("reloadTable")
    static let reConnect = Notification.Name("reConnect")
}
