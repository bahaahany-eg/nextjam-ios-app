//
//  JamSessionVC.swift
//  NextJAM
//
//  Created by apple on 15/09/21.
//

import UIKit
import Segmentio
import SocketIO

class JamSessionVC: UIViewController,UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var segmentioView: Segmentio!
    
    //MARK: - Variables
    var refresher:UIRefreshControl!
    
    
    var currentPage = 0
    var SessionsList =  [Room]()
    var filteredSession = [Room]()
    var isfiltered = false
    var refresh = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionVw.delegate = self
        collectionVw.dataSource = self
        NavigationButtons()
        TopTabView()
        self.searchTF.delegate = self
        self.SessionsList.removeAll()
//        fetchSessions()
        self.setupPullToRefresh()
        self.searchTF.isEnabled = false
    }
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        self.collectionVw.refreshControl?.beginRefreshing()
        self.currentPage = 0
        fetchSessions()
        self.refresher.endRefreshing()
    }
    
    //MARK: - Playlist End Fetch Songs From Server
    func setupPullToRefresh(){
        self.refresher = UIRefreshControl()
        self.collectionVw!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.white
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionVw!.addSubview(refresher)
    }
    
    //MARK: - Load Songs Data from server
    @objc func loadData() {
        self.refresher.beginRefreshing()
        self.currentPage = 0
        self.refresh = true
        fetchSessions()
    }
    
    //MARK: - Create Session Action
    @objc func CreateSessionAction(_ sender: Any) {
        let vc = RouteCoordinator.NavigateToVC(with: "PartySceduleVC", Controller: "PartySceduleVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen)
        let NavigationController = UINavigationController(rootViewController: vc)
        NavigationController.modalPresentationStyle = .fullScreen
        self.present(NavigationController, animated: true, completion: nil)
    }
    
    @objc func ProfileAction(_ sender: Any) {
        let vc = RouteCoordinator.NavigateToVC(with: "SettingsVC", Controller: "SettingsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen)
        //        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func JoinSessionAction(_ sender: Any){
        
//        let alart = UIAlertController(title: "Join Session", message: "Enter Invitation code to join session", preferredStyle: .alert)
//        alart.addTextField { text in
//            print(text)
//        }
//        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
//            guard let text = alart.textFields?.first?.text else { return }
//            self.joinRoom(inviteCode: text)
//        }
//
//        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
//        alart.addAction(ok)
//        alart.addAction(cancel)
//        self.present(alart, animated: true, completion: nil)
        
        DispatchQueue.main.async {
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let alert = Utility().showAlert(hasTextField: false, title: "Comming Soon", Msg: "This feature is yet to be built.", style: .alert, Actions: [ok])
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func joinRoom(inviteCode:String){
        guard let nickname = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        SocketIOManager.sharedInstance.connectToServerWithNickName(nickName: nickname , inviteCode: inviteCode) { userList in
            print(userList)
        }
        guard let vc = RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen) as? RoomPlayListVC else { return }
        vc.fromNotification = false
        vc.joined = true
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - Jam Session UI Extension
extension JamSessionVC {
    func NavigationButtons(){
        let nav = self.navigationController?.navigationBar
        nav?.topItem?.title = "JamSession"
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [.foregroundColor: UIColor.white]
        //MARK: - Create Session Button
        let CreateSession = UIButton(type: .custom)
        CreateSession.setImage(UIImage(systemName: "plus.circle")?.withTintColor(.white), for: .normal)
        CreateSession.addTarget(self, action: #selector(CreateSessionAction), for: .touchUpInside)
        //MARK: - Join Session Button
        let Join = UIButton(type: .custom)
        Join.setImage(UIImage(systemName: "badge.plus.radiowaves.right")?.withTintColor(.white), for: .normal)
        Join.addTarget(self, action: #selector(JoinSessionAction), for: .touchUpInside)
        //MARK: - Profile Button
        let profile = UIButton(type: .custom)
        profile.setImage(UIImage(systemName: "person")?.withTintColor(.white), for: .normal)
        profile.addTarget(self, action: #selector(ProfileAction), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: CreateSession),UIBarButtonItem(customView: profile),UIBarButtonItem(customView: Join)]
    }
}

//MARK: - Top Segmentio View
private extension JamSessionVC {
    func pendingAlert(){
        DispatchQueue.main.async {
            let okay = UIAlertAction(title: "Ok", style: .default)
            let alert = Utility().showAlert(hasTextField: false, title: "Coming Soon", Msg: "This screen is pending", style: .alert, Actions: [okay])
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: - Top Tab View Configuration
    func TopTabView(){
        var content = [SegmentioItem]()
        let Recent = SegmentioItem(title: "Recent",image: nil)
        let PeopleTab = SegmentioItem(title: "People", image: nil)
        let LocalTab = SegmentioItem(title: "Local", image: nil)
        content.append(Recent)
        content.append(PeopleTab)
        content.append(LocalTab)
        
        segmentioView.selectedSegmentioIndex = 0
        
        let indicator =  SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            color: #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        )
        let  state = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .black,
                titleFont: UIFont.systemFont(ofSize:20),
                titleTextColor: .white
            ),
            selectedState: SegmentioState(
                backgroundColor: .black,
                titleFont: UIFont.systemFont(ofSize:20),
                titleTextColor: .white
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.systemFont(ofSize:20),
                titleTextColor: .white
            )
        )
        let option = SegmentioOptions(
            backgroundColor: .black,
            segmentPosition: .fixed(maxVisibleItems: 3),
            scrollEnabled: false,
            indicatorOptions: indicator,
            horizontalSeparatorOptions: .none,
            verticalSeparatorOptions: .none,
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: state
        )
        segmentioView.setup(
            content: content,
            style: .onlyLabel,
            options: option
        )
    }
    

    
}

//MARK: - CollectionView Delegate, DataSource
extension JamSessionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch isfiltered {
        case true:
            return self.filteredSession.count
        case false:
            return self.SessionsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JamSessionCell", for: indexPath) as! JamSessionCell
        if isfiltered{
            cell.liveSessionView.layer.cornerRadius = 2
            cell.mmberTimeView.layer.cornerRadius = cell.mmberTimeView.frame.height / 2
            cell.sessionLbl.text = self.filteredSession[indexPath.item].roomName
            cell.hostedTime.text = self.filteredSession[indexPath.item].startsAt
            cell.locationLbl.text = self.filteredSession[indexPath.item].inviteCode
        } else {
            cell.liveSessionView.layer.cornerRadius = 2
            cell.mmberTimeView.layer.cornerRadius = cell.mmberTimeView.frame.height / 2
            cell.sessionLbl.text = self.SessionsList[indexPath.item].roomName
            cell.hostedTime.text = self.SessionsList[indexPath.item].startsAt
            cell.locationLbl.text = self.SessionsList[indexPath.item].inviteCode
            cell.hostNameLbl.text = "@\(self.SessionsList[indexPath.row].hostUsername)"
            if let base64 = self.SessionsList[indexPath.row].hostProfileImage {
                if base64.count > 10 {
//                    cell.hostImage.ConvertBase64ToImage(imageBase64String: base64)
                    cell.hostImage.MakeRound()
                }else{
                    cell.hostImage.image = UIImage(named: "album")
                    cell.hostImage.MakeRound()
                }
            }

            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let vc = RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen) as? RoomPlayListVC else { return }
        if isfiltered {
            vc.RoomID = self.filteredSession[indexPath.row].roomID
            vc.invitationCode = self.filteredSession[indexPath.row].inviteCode

            vc.AsGuest = true
        }else {
            vc.sessionDetails = self.SessionsList[indexPath.row]
            vc.AsGuest = true
        }
        let NavigationController = UINavigationController(rootViewController: vc)
        NavigationController.modalPresentationStyle = .fullScreen
        self.present(NavigationController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if !isfiltered{
                if indexPath.item > 4{
                    if indexPath.item == (self.SessionsList.count - 1) {
                        self.currentPage += 1
                        fetchSessions()
                    }
                }
            }
        }

    
    
}

//MARK: - CollectionView FlowLayout
extension JamSessionVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width/2 - 16, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
}

/// Extension for API Call
private extension JamSessionVC {
    //MARK: - Fetch All Sessions List
    func fetchSessions(){
        WebLayerUserAPI().getAllSession(page: currentPage) { sessions in
            if sessions.rooms.count > 0{
                if self.currentPage == 0 {
                    if self.refresh {
                        self.SessionsList.removeAll()
                        self.refresh = false
                    }
                    sessions.rooms.forEach { room in
                        
                        self.SessionsList.append(room)
                    }
                    self.sortSessios()
                }else {
                    sessions.rooms.forEach { room in
                        self.SessionsList.append(room)
                    }
                    self.sortSessios()
                }
                
            }
            
        } failure: { error in
            print(error)
        }
        
    }
    
    
    
    func sortSessios() {
        var tempArr = [Room]()
        self.SessionsList.forEach {
            let uniqueId = $0.roomID
            if !(tempArr.contains(where: {$0.roomID == uniqueId})){
                tempArr.append($0)
            }
            self.SessionsList = tempArr
            DispatchQueue.main.async {
                self.collectionVw.reloadData()
                let isRefreshing = self.refresher.isRefreshing
                if isRefreshing {
                    self.refresher.endRefreshing()
                }
            }
        }
    }
}

//MARK: - Search Field
extension JamSessionVC{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let searchtext = textField.text else { return }
        if ( searchtext.count > 0) {
            isfiltered = true
            self.SessionsList.forEach {
                let name = $0.roomName
                if name.contains(searchtext) {
                    self.filteredSession.append($0)
                    self.collectionVw.reloadData()
                }
            }
        }else {
            self.collectionVw.reloadData()
            isfiltered = false
        }
    }
}


