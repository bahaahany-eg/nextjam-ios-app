//
//  SearchViewController.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 23/08/21.
//

import UIKit
import MediaPlayer
import StoreKit
import CoreData


protocol SearchVCProtocol {
    func getSongListDelegateMethod()
}

class SearchVC: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var searchMusicSearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    //MARK: - Variable
    var mediaItems = [[MediaItem]]()
    var mediaPlaylist: MPMediaPlaylist!
    let playlistUUIDKey = "playlistUUIDKey"
    var playlistUUID = UUID()
    var userType = ""
    var inviteCode = ""
    var roomId = ""
    var selected = [Bool]()
    
    
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    
    var delegate: SearchVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchMusicSearchBar.delegate = self
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        //MARK: - Adding Socket Handlers for music_search listner
        RoomPlayListVC().searchListener(called: "from searchVC")
        RoomPlayListVC().SessionEndListner()


    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.getSongListDelegateMethod()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    
    @IBAction func action_backbtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchVC {
    
    //MARK: - Add To Playlist Method
    @objc func didTapAddToPlaylist(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        selected[sender.tag] = true
        let UD = Constants.staticString.USER_DEFAULTS.self
        guard let username = UD.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        SocketIOManager.sharedInstance.searchForSongOverSocket(username: username, song: mediaItems[0][sender.tag].identifier, songImage: mediaItems[0][sender.tag].artwork.SongImageURL ?? "", type: "song", artistName: mediaItems[0][sender.tag].artistName, name: mediaItems[0][sender.tag].name, inviteCode:self.inviteCode) { data in
            print(data)
            print("add song in this room")
        }
    }
    
}
extension SearchVC: UISearchBarDelegate {
    //MARK: - Search API CAll
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text else{
            return
        }
        APIManager().performAppleMusicCatalogSearch(with: searchString, countryCode: "us") { medias, error in
            guard error == nil else{
                return
            }
            self.mediaItems = medias
            self.setupDefaultSelected()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.searchResultTableView.reloadData()
            }
        }
    }
    

    func setupDefaultSelected() {
        if self.mediaItems.count != 0 {
            let count = self.mediaItems[0].count
            self.selected.removeAll()
            for _ in 0..<count{
                self.selected.append(false)
            }

        }
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediaItems.first?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else{
            return UITableViewCell.init()
        }
        cell.songTitleLabel.text = self.mediaItems.first?[indexPath.row].name
        loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: self.mediaItems.first?[indexPath.row].artwork.SongImageURL, imageView: cell.songImage)
        cell.addToPlaylistButton.tag = indexPath.row
        cell.addToPlaylistButton.addTarget(self, action: #selector(didTapAddToPlaylist(_:)), for: .touchUpInside)
        if selected[indexPath.row]{
            cell.addToPlaylistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }else {
            cell.addToPlaylistButton.setImage(UIImage(systemName: "Plus"), for: .normal)
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        cell.addToPlaylistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        selected[indexPath.row] = true
        let UD = Constants.staticString.USER_DEFAULTS.self
        guard let username = UD.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        SocketIOManager.sharedInstance.searchForSongOverSocket(username: username, song: mediaItems[0][indexPath.row].identifier, songImage: mediaItems[0][indexPath.row].artwork.SongImageURL ?? "", type: "song", artistName: mediaItems[0][indexPath.row].artistName, name: mediaItems[0][indexPath.row].name, inviteCode:self.inviteCode) { data in
            print("add song in this room")
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
    
}

