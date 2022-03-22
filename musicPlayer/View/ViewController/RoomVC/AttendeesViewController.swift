//
//  AttendeesViewController.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 16/09/21.
//

import UIKit
import SDWebImage

class AttendeesViewController: UIViewController {

    @IBOutlet weak var attendeesCollectionVw: UICollectionView!
    

    ///Variables
    var usernm = ""
    var roomId = ""
    var followers = [Followers]()
    var members = [Attendee]()
    var fromProfile = true
    var pageCount = 1
    var isPageRefreshing:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fromProfile ? "Followers" : "Attendees"
        attendeesCollectionVw.register(UINib(nibName: "AttendeesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AttendeesCollectionViewCell")
        attendeesCollectionVw.delegate = self
        attendeesCollectionVw.dataSource = self
        fromProfile ? self.getFollowers() : self.getMembers()
        setupBottomRefreshIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor =  UIColor(named: "JAM")
    }
    
    
    //MARK: - Get Members
    func getMembers(){
        WebLayerUserAPI().getAttendeeFor(room: self.roomId) { data in
            DispatchQueue.main.async { [self] in
                members = data
                print("members",members)
                attendeesCollectionVw.reloadData()
            }
        } failure: { error in
            
        }
    }
    
    //MARK: - Get Followers
    func getFollowers(){
        WebLayerUserAPI().getFollower(for: self.usernm, page: self.pageCount) { fol in
            DispatchQueue.main.async {
                if self.pageCount == 1{
                    self.followers = fol.users
                }else{
                    fol.users.forEach { fl in
                        self.followers.append(fl)
                    }
                }
                if self.pageCount <= 3{
                    if fol.users.count == 10 {
                        self.pageCount += 1
                        self.getFollowers()
                    }
                }
                self.attendeesCollectionVw.reloadData()
            }
        } failure: { err in
            print(err)
        }
    }
}




extension AttendeesViewController {

    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension AttendeesViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fromProfile ? self.followers.count : self.members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttendeesCollectionViewCell", for: indexPath) as? AttendeesCollectionViewCell else{return UICollectionViewCell.init()}
        let url = fromProfile ? self.followers[indexPath.row].profileImage : self.members[indexPath.row].profileImage
        if url.contains("http"){
            cell.attendeesImgVw.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "person.fill"))
        }else{
            let completeURL = Constants.APIUrls.GetImage+url
            if fromProfile{
                cell.attendeesImgVw.sd_setImage(with: URL(string: completeURL), placeholderImage: UIImage(systemName: "person.fill"))
            }else{
                cell.attendeesImgVw.sd_setImage(with: URL(string: completeURL), placeholderImage: UIImage(systemName: "person.fill"))
            }
        }
        
        
        cell.MakeRound()
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.red.cgColor
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        RouteCoordinator.NavigateToVC(with: "ProfileVC", Controller: "ProfileVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen, ofType: ProfileVC()) { [self] vc in
            vc.uname = fromProfile ? self.followers[indexPath.row].username : self.members[indexPath.row].username
            guard let cell = self.attendeesCollectionVw.cellForItem(at: indexPath) as? AttendeesCollectionViewCell else {return}
            vc.image = cell.attendeesImgVw.image!
            guard let myname = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            let selectedName = fromProfile ? self.followers[indexPath.row].username : self.members[indexPath.row].username
            if selectedName == myname { vc.myprofile = true }
            else{ vc.myprofile = false }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds
        return CGSize(width: size.width/4-16, height: size.width/4-16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    @objc func paginateMore(){
        if fromProfile{
            if(self.attendeesCollectionVw.contentOffset.y >= (self.attendeesCollectionVw.contentSize.height - self.attendeesCollectionVw.bounds.size.height)) {
                if !isPageRefreshing {
                    isPageRefreshing = true
                    self.pageCount += 1
                    self.getFollowers()
                    self.attendeesCollectionVw.reloadData()
                }
                
            }
        }
    }
    
    
    func setupBottomRefreshIndicator(){
        let refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        refreshControl.triggerVerticalOffset = 50.0
        refreshControl.addTarget(self, action: #selector(paginateMore), for: .valueChanged)
        self.attendeesCollectionVw.bottomRefreshControl = refreshControl
    }
    
}
