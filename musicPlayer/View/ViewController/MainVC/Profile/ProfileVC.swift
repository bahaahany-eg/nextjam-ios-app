//
//  ProfileVC.swift
//  NextJAM
//
//  Created by apple on 15/09/21.
//

import UIKit

class ProfileVC: UIViewController {

///Outlets
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var displayname: UILabel!
    
    @IBOutlet weak var friendsCollections: UICollectionView!
    
    @IBOutlet weak var albumCollection: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.friendsCollections.delegate = self
        self.friendsCollections.dataSource = self
        self.albumCollection.delegate = self
        self.albumCollection.dataSource = self

        self.BackButton()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    ///MARK: - View All button Action
    @IBAction func ViewAllButtonAction(_ sender: Any) {
        let vc = RouteCoordinator.NavigateToVC(with: "AttendeesViewController", Controller: "AttendeesViewController", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen)
        let NavigationController = UINavigationController(rootViewController: vc)
        NavigationController.modalPresentationStyle = .fullScreen
        self.present(NavigationController, animated: true, completion: nil)
    }
    //MARK: - Navigation Bar Cancel Button
    
    func BackButton (){
        let CancelButton = UIButton(type: .custom)
        CancelButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white), for: .normal)
        CancelButton.setTitle("Back", for: .normal)
        CancelButton.setTitleColor(UIColor.white, for: .normal)
        CancelButton.addTarget(self, action: #selector(CancelButtonAction), for: .touchUpInside)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: CancelButton)
    }
    
    
    
    //MARK: - Cancel Button Action
    @objc func CancelButtonAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUI(){
        self.userProfilePicture.image = UIImage(named: "dummy")
        self.userProfilePicture.contentMode = .scaleAspectFill
        self.userProfilePicture.MakeRound()
    }
}


extension ProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems : Int = 0
        if collectionView == self.friendsCollections {
            numberOfItems = 12
        } else if collectionView == self.albumCollection {
            numberOfItems = 12
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var item : UICollectionViewCell!
        if collectionView == self.friendsCollections {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsListCell", for: indexPath) as? FriendsListCell else {
                return UICollectionViewCell.init()
            }
            item =  cell
            cell.friendProfileImage.image = UIImage(named: "dummy")
            cell.friendProfileImage.contentMode = .scaleToFill
            cell.MakeRound()
            
        }
        else if collectionView == self.albumCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionCell", for: indexPath) as? AlbumCollectionCell else {
                return UICollectionViewCell.init()
            }
            cell.albumImage.image = UIImage(named: "dummy")
            cell.albumImage.contentMode = .scaleToFill
            
            item =  cell
        }
        
        return item
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        var size : CGSize = CGSize(width: 0, height: 0)
        if collectionView == self.friendsCollections {
            size = CGSize(width: screenSize.width/7-8, height: screenSize.width/7-8)
        } else if collectionView == self.albumCollection {
            size = CGSize(width: screenSize.width/3-24, height: 215)
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
