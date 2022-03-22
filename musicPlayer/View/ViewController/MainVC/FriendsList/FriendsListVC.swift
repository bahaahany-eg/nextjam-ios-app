//
//  FriendsListVC.swift
//  NextJAM
//
//  Created by apple on 15/09/21.
//

import UIKit

class FriendsListVC: UIViewController {

    @IBOutlet weak var collectionVw: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionVw.delegate = self
        self.collectionVw.dataSource = self
    }
    
}


extension FriendsListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsListCell", for: indexPath) as? FriendsListCell else { return UICollectionViewCell.init()
        }
        cell.friendProfileImage.image = UIImage(named: "dummy")
        cell.friendProfileImage.layer.cornerRadius = cell.friendProfileImage.frame.height / 2
        return cell
    }
    
}
