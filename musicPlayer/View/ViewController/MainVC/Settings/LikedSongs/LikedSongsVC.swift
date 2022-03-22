//
//  LikedSongsVC.swift
//  NextJAM
//
//  Created by apple on 24/11/21.
//

import UIKit

class LikedSongsVC: UIViewController, UITableViewDelegate,UITableViewDataSource {

    ///Outlets
    @IBOutlet weak var tblView: UITableView!
    
    
    ///Variables
    var liked = [likedSong]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        self.title = "Liked Songs"
        
        getLikedSongs()
    }

    //MARK: - Function to fetch the liked songs for the user.
    func getLikedSongs(){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else {return}
        WebLayerUserAPI().fetchUserLikedSongs(username: username) { data in
            self.liked = data
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        } failure: { error in
            print(error)
        }
    }
    
    //MARK: - Function to unlike the song listed in the list
    @objc func unlikeAction(_ sender: UIButton){
        guard let id = self.liked[sender.tag].songTitle as? String else{ return }
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().unlikeSong(with: Int(id)!, username: username) { data in
            print(data)
            self.getLikedSongs()
        } failure: { error in
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.liked.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "LikedSongCell", for: indexPath) as? LikedSongCell else{ return UITableViewCell.init()}
         cell.songTitle.text = self.liked[indexPath.row].name
         cell.artistName.text = self.liked[indexPath.row].artistName
         guard let url = URL(string: self.liked[indexPath.row].imageURL) else { return UITableViewCell.init()}
         cell.imgUrl.ImageLoader(fromURL:url, placeHolderImage: UIImage(named: "NextJamLogo")!)
         cell.likeBtn.tag = indexPath.row
         cell.likeBtn.addTarget(self, action: #selector(unlikeAction(_:)), for: .touchUpInside)
         cell.selectionStyle = .none
        

        return cell
    }
}
