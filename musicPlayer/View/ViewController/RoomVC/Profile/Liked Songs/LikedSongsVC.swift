//
//  LikedSongsVC.swift
//  NextJAM
//
//  Created by apple on 23/11/21.
//

import UIKit

class LikedSongsVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    ///Outlets
    @IBOutlet weak var tblView: UITableView!
    
    
    ///Variables
    var songs = [likedSong]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.title = "Liked Songs"
        getSongs()
    }
    func getSongs(){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().fetchUserLikedSongs(username: username) { data in
            self.songs = data
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        } failure: { error in
            print(error)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LikedSongCell") as? LikedSongCell else{ return UITableViewCell.init()}
        cell.songTitle.text = self.songs[indexPath.row].name
        cell.artistName.text = self.songs[indexPath.row].artistName
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(HeartAction(_:)), for: .touchUpInside)
        return cell
    }
    
    
    @objc func HeartAction(_ sender : UIButton){
        let song = self.songs[sender.tag]
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        WebLayerUserAPI().unlikeSong(with: song.songTitle, username: username) { status in
            if status {
                DispatchQueue.main.async {
                    sender.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        } failure: { err in
            print(err)
        }

    }
}
