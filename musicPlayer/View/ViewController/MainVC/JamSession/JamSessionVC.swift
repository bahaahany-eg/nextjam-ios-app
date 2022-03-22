//
//  JamSessionVC.swift
//  NextJAM
//
//  Created by apple on 15/09/21.
//

import UIKit
import Segmentio
import SocketIO
import Alamofire
import Messages
import MessageUI
import SDWebImage

class JamSessionVC: UIViewController,UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var searchTF: UITextField! {
        didSet{
            searchTF.setLeftView(image: UIImage.init(systemName: "magnifyingglass")!)
            searchTF.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3764821291, green: 0.4897046685, blue: 0.5447942019, alpha: 1) ])
        }
    }
    
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var statusView: UIView!
    
    //MARK: - Variables
    var refresher:UIRefreshControl!
    let composeVC = MFMessageComposeViewController()
    var currentPage = 1
    var SessionsList =  [Room]()
    var filteredSession = [Room]()
    var isfiltered = false
    var refresh = false
    var segmentIndex : Int = 0
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        composeVC.messageComposeDelegate = self
        collectionVw.delegate = self
        collectionVw.dataSource = self
        NavigationButtons()
        customSegment(selectedIndex:self.segmentIndex, update: false)
        self.searchTF.delegate = self
        self.searchTF.autocorrectionType = .no
        self.SessionsList.removeAll()
        self.setupGesture()
        self.setupPullToRefresh()

    }
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        self.collectionVw.refreshControl?.beginRefreshing()
        self.currentPage = 1
        if segmentIndex == 0 || segmentIndex == 1 {
            fetchSessions()
        }else {
            userSessions()
        }
        
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
        if segmentIndex == 0 {
            self.refresher.beginRefreshing()
            self.currentPage = 1
            self.refresh = true
            fetchSessions()
        }else if segmentIndex == 2 {
            self.refresher.beginRefreshing()
            self.currentPage = 1
            self.refresh = true
            userSessions()
        }
    }
    
    //MARK: - Create Session Action
    @objc func CreateSessionAction(_ sender: Any) {

        RouteCoordinator.NavigateToVC(with: "PartySceduleVC", Controller: "PartySceduleVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: PartySceduleVC()) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    @objc func ProfileAction(_ sender: Any) {
        RouteCoordinator.NavigateToVC(with: "SettingsVC", Controller: "SettingsVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: SettingsVC()) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func JoinSessionAction(_ sender: Any){
        self.composeVC.recipients = ["999999999","11111","11111232","21342314","2342134"]
        self.composeVC.body = "Join next jam here a awesome party is going on."
        if MFMessageComposeViewController.canSendText(){
            DispatchQueue.main.async {
                self.present(self.composeVC, animated: true, completion: nil)
            }
        }
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    let alert = Utility().showAlert(hasTextField: false, title: "Comming Soon", Msg: "This feature is yet to be built.", style: .alert, Actions: [ok])
                    self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
            break
        case .sent:
            controller.dismiss(animated: true, completion: nil)
            break
        case .failed:
            break
        }
    }
}

//MARK: - Jam Session UI Extension
extension JamSessionVC {
    func NavigationButtons(){
        guard let nav = self.navigationController?.navigationBar else { return }
        nav.topItem?.title = "Jam Sessions"
        nav.barStyle = UIBarStyle.black
        nav.tintColor = UIColor(named: "JAM")
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //MARK: - Create Session Button
        let CreateSession = UIButton(type: .custom)
        CreateSession.setTitle("Start", for: .normal)
        CreateSession.backgroundColor = UIColor(named: "sGreen")
        CreateSession.tintColor = UIColor(named: "sGreen")
        CreateSession.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        CreateSession.layer.cornerRadius = 8
        CreateSession.addTarget(self, action: #selector(CreateSessionAction), for: .touchUpInside)
        CreateSession.BarButtonWithCustomImage()
       
        //MARK: - Profile Button
        let profile = UIButton(type: .custom)
        profile.setImage(UIImage(named: "Settings")?.withTintColor(.white), for: .normal)
        profile.addTarget(self, action: #selector(ProfileAction), for: .touchUpInside)
        profile.BarbuttonChangeUX(isCustom: true)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profile)]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: CreateSession)]
        
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
    
    func StatusColor(Status:String)->UIColor{
        
        var color = UIColor.clear
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JamSessionCell", for: indexPath) as! JamSessionCell
        if isfiltered{
            cell.liveSessionView.layer.cornerRadius = 2
            cell.mmberTimeView.layer.cornerRadius = cell.mmberTimeView.frame.height / 2
            cell.sessionLbl.text = self.filteredSession[indexPath.item].roomName
            let date = NSDate(timeIntervalSince1970: Double(self.filteredSession[indexPath.row].startsAt)!)
            cell.hostedTime.text = Utility().difference(from: date as Date)
            cell.locationLbl.text = self.filteredSession[indexPath.item].roomStatus
            cell.hostNameLbl.text = "@\(self.filteredSession[indexPath.row].hostUsername)"
            if let img = self.filteredSession[indexPath.row].hostProfileImage {
                cell.hostImage.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "person.fill"))
                cell.hostImage.MakeRound()
            }
            cell.hostImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.userprofileAction(_:)))
            cell.hostImage.addGestureRecognizer(gesture)
            cell.statusView.backgroundColor = StatusColor(Status: self.filteredSession[indexPath.row].roomStatus)
            cell.statusView.MakeRound()
            cell.playbtnIcon.MakeRound()
        } else {
            cell.liveSessionView.layer.cornerRadius = 2
            cell.mmberTimeView.layer.cornerRadius = cell.mmberTimeView.frame.height / 2
            cell.sessionLbl.text = self.SessionsList[indexPath.item].roomName
            let date = NSDate(timeIntervalSince1970: Double(self.SessionsList[indexPath.row].startsAt)!)
            cell.hostedTime.text = Utility().difference(from: date as Date)
            cell.locationLbl.text = self.SessionsList[indexPath.item].roomStatus
            cell.hostNameLbl.text = "@\(self.SessionsList[indexPath.row].hostUsername)"
            if let img = self.SessionsList[indexPath.row].hostProfileImage {
                cell.hostImage.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "person.fill"))
                    cell.hostImage.MakeRound()
            }
            cell.hostImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.userprofileAction(_:)))
            cell.hostImage.addGestureRecognizer(gesture)
            cell.statusView.backgroundColor = StatusColor(Status: self.SessionsList[indexPath.row].roomStatus)
            cell.statusView.MakeRound()
            cell.playbtnIcon.MakeRound()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SocketIOManager.sharedInstance.establishConnection()
        
        let session : Room
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        if isfiltered {
            session = self.filteredSession[indexPath.row]
            
        }else{
            session = self.SessionsList[indexPath.row]
        }
        session.hostUsername == username ? self.goToPlaylist(session: session,asGuest:false) : self.goToPlaylist(session: session, asGuest: true)
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
    
    func goToPlaylist(session: Room,asGuest:Bool){
        
        RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: RoomPlayListVC()) { vc in
            vc.sessionDetails = session
            vc.AsGuest = asGuest
            vc.fromSessions = true
            let NavigationController = UINavigationController(rootViewController: vc)
            NavigationController.modalPresentationStyle = .fullScreen
            
            asGuest ? self.navigationController?.pushViewController(vc, animated: true) : self.present(NavigationController, animated: true, completion: nil)
        }
    }
    
    @objc func userprofileAction(_ gesture:UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.collectionVw)
        if let tappedIndexPath = self.collectionVw.indexPathForItem(at: tapLocation){
            guard let cell = self.collectionVw.cellForItem(at: tappedIndexPath) as? JamSessionCell else { return }
            RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { vc in
                vc.image = cell.hostImage.image!
                vc.uname = self.isfiltered ? self.filteredSession[tappedIndexPath.row].hostUsername : self.SessionsList[tappedIndexPath.row].hostUsername
                guard let myName = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
                let ssn = self.isfiltered ? self.filteredSession[tappedIndexPath.row] :self.SessionsList[tappedIndexPath.row]
                if ssn.hostUsername == myName {
                    vc.myprofile = true
                }else {
                    vc.myprofile = false
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
}

//MARK: - CollectionView FlowLayout
extension JamSessionVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width/2 - 16, height: 305)
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
    /*
     This method is used to call api for fetching the session from the server.
     */
    
    func fetchSessions(){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().getAllSession(usrname:username,page: currentPage) { sessions in
            if sessions.rooms.count > 0{
                if self.currentPage == 1 {
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
    
    //MARK: - Fetch All User's  Sessions List
    /*
     This method is used to call api for fetching the session of the user from the server.
     */
    func userSessions(){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{ return }
        WebLayerUserAPI().fetchSessionForUser(with: username) { sessions in
            if self.segmentIndex == 2 {
                self.isfiltered = true
            }
            if sessions.rooms.count > 0{
                self.filteredSession = sessions.rooms
                self.sortSessiosByOrder(session: self.filteredSession)
            } else if sessions.rooms.isEmpty {
                self.isfiltered = true
                self.filteredSession = [Room]()
                DispatchQueue.main.async {
                    self.collectionVw.reloadData()
                    let isRefreshing = self.refresher.isRefreshing
                    if isRefreshing {
                        self.refresher.endRefreshing()
                    }
                }
            }
        } failure: { error in
            print(error)
        }

    }
    
    //MARK: - Sort Session by order
    /*
     This method is used to sorted the fetched session by order Live --> Schedule --> Ended
    */
    
    func sortSessiosByOrder(session: [Room]){
        var tempArr = [Room]()
        var rearrenged = [Room]()
        session.forEach {
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
            self.filteredSession = rearrenged
            
            DispatchQueue.main.async {
                self.collectionVw.reloadData()
                let isRefreshing = self.refresher.isRefreshing
                if isRefreshing {
                    self.refresher.endRefreshing()
                }
            }
        }
    }
    
    //MARK: - Sort Session by order
    /*
     This method is used to sorted the fetched session by order Live --> Schedule --> Ended
    */
    func sortSessios() {
        var tempArr = [Room]()
        var rearrenged = [Room]()
        self.SessionsList.forEach {
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
            self.SessionsList = rearrenged
            
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let query = textField.text else { return false }
        if query == "" {
            self.isfiltered = false
            fetchSessions()
        }
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        guard let searchtext = textField.text else { return }
//        if ( searchtext.count > 0) {
//            isfiltered = true
//            self.SessionsList.forEach {
//                let name = $0.roomName
//                if name.contains(searchtext) {
//                    self.filteredSession.append($0)
//                    self.collectionVw.reloadData()
//                }
//            }
//        }else {
//            self.collectionVw.reloadData()
//            isfiltered = false
//        }
//    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("***\(textField.text)***")
        guard let query = textField.text else { return false }
        if query.isEmpty {
            self.isfiltered = false
            fetchSessions()
        }else{
            WebLayerUserAPI().search(with: query, page: "1") { data in
                print("search results:====>\(data)")
                DispatchQueue.main.async {
                    self.isfiltered = true
                    print(data.rooms)
                    self.filteredSession = data.rooms
                    self.collectionVw.reloadData()
                }
            } failure: { error in
                print(error)
            }

        }
        return true
    }
    
}


//MARK: - Extension for the top segment on this controller
extension JamSessionVC {
    func customSegment(selectedIndex: Int,update:Bool){
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
        segment.buttonTitles = "Recent,Live,My Sessions"
        segment.textColor = .white
        segment.selectorTextColor = .white
        segment.selectorColor = #colorLiteral(red: 0.5985194445, green: 0.1699213684, blue: 0.3734838367, alpha: 1)
        segment.selectedSegmentIndex = selectedIndex
        if !update{
            self.view.addSubview(segment)
        }
        segment.onValueChanged = {[self] index in
            print("I have selected index \(index) from Segment")
            guard let searchQuery = self.searchTF.text else { return }
            if !searchQuery.isEmpty {
                self.searchTF.text = ""
            }
            self.segmentIndex = index
            reloadData(for: self.segmentIndex)
        }
    }
 
    //MARK: - Handled UI for Top Segments
    /*
     This method is used to update the UI as the user tap on the segments
    */
    func reloadData(for index:Int){
        switch index {
        case 0:
            self.isfiltered = false
            
            DispatchQueue.main.async {
                self.collectionVw.reloadData()
                let isRefreshing = self.refresher.isRefreshing
                if isRefreshing {
                    self.refresher.endRefreshing()
                }
            }
            break
        case 1:
            self.isfiltered = true
            self.filteredSession.removeAll()
            self.SessionsList.forEach {
                let status = $0.roomStatus
                if "LIVE" == status{
                    self.filteredSession.append($0)
                }
                DispatchQueue.main.async {
                    self.collectionVw.reloadData()
                    let isRefreshing = self.refresher.isRefreshing
                    if isRefreshing {
                        self.refresher.endRefreshing()
                    }
                }
            }
            break
        case 2:
            userSessions()
            break
        
        default:
            break
        }
    }
    
    func setupGesture(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                if self.segmentIndex != 0{
                    self.customSegment(selectedIndex: self.segmentIndex, update: true)
                }
            case .left:
                if self.segmentIndex < 2  {
                    self.customSegment(selectedIndex: self.segmentIndex,update: true)
                }
            default:
                break
            }
        }
    }

}



