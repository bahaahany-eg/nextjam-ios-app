//
//  AttendeesViewController.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 16/09/21.
//

import UIKit

class AttendeesViewController: UIViewController {

    @IBOutlet weak var attendeesCollectionVw: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Attendees"
        attendeesCollectionVw.register(UINib(nibName: "AttendeesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AttendeesCollectionViewCell")
        attendeesCollectionVw.delegate = self
        attendeesCollectionVw.dataSource = self
        self.BackButton()
    }
    
}

extension AttendeesViewController {
    
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
}

extension AttendeesViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttendeesCollectionViewCell", for: indexPath) as? AttendeesCollectionViewCell else{return UICollectionViewCell.init()}
        cell.attendeesImgVw.image = UIImage(named: "dummy")
        cell.MakeRound()
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.red.cgColor
        return cell
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
    
    
}
