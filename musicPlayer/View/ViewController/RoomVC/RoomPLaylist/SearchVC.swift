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
    func getSongListDelegateMethod(isSearching:Bool)
    func updateSongWithCurrentPlaying()

}


//MARK: - This is the search Viewcontroller used on the playlist Contrroller to search songs and add them to playlist
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
    var isSearching = true
    var playlistArray = [MPMediaItemCollection]()
    
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    
    var delegate: SearchVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchMusicSearchBar.delegate = self
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        if isSearching {
            //MARK: - Adding Socket Handlers for music_search listner
            RoomPlayListVC().searchListener(called: "from searchVC")
            RoomPlayListVC().SessionEndListner()
            searchMusicSearchBar.isHidden = false
        }else{
            searchMusicSearchBar.isHidden = true
            loadPlaylistFromUserLibrary()
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.getSongListDelegateMethod(isSearching: self.isSearching)
        delegate?.updateSongWithCurrentPlaying()
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
    //MARK: - This function is used to get playlist from the user library to import them to the room playlist.
    /**
            In this playlist only with the MPMEdiaPlaylistPropertyCloudGllobalID will be shown.
    */
    func loadPlaylistFromUserLibrary(){
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        var temp = [MPMediaItemCollection]()
        for playlist in playlists! {
            print("================>\n")
            print("ID: \(playlist.value(forProperty: MPMediaPlaylistPropertyCloudGlobalID) as! String != "")")
            print("\n<================")
            if (playlist.value(forProperty: MPMediaPlaylistPropertyCloudGlobalID) as! String) != "" {
                temp.append(playlist)
            }
        }
        self.playlistArray = temp
        self.setupDefaultSelected()
        self.searchResultTableView.reloadData()
    }
    
    //MARK: - This function is used to send song to the socket when user tap on them from the list
    /**
        After taping on the song from the list it will fire the socket event with the song data which is listed below
     # Lists
     
     Required arguments by this function:
     
     1. song: String (song identifier)
     2. inviteCode : String (Room invitation code)
     3. songName : String (Song title)
     4. SongImage: String ( song artwork image)
     5. username: String
     6.artistName : String ( song artist name)
     
    */
    
    
    @objc func didTapAddToPlaylist(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        selected[sender.tag] = true
        let UD = Constants.staticKeys.USER_DEFAULTS.self
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
        //Pass the country code from the storefront id for a user
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
        if isSearching{
            if self.mediaItems.count != 0 {
                let count = self.mediaItems[0].count
                self.selected.removeAll()
                for _ in 0..<count{
                    self.selected.append(false)
                }
            }
        }else{
            if self.playlistArray.count != 0 {
                let count = self.playlistArray.count
                self.selected.removeAll()
                for _ in 0..<count{
                    self.selected.append(false)
                }
            }
        }
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        if isSearching{
            row = self.mediaItems.first?.count ?? 0
        }else{
            row = playlistArray.count
        }
        return row
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else{
            return UITableViewCell.init()
        }
        if isSearching {
            cell.songTitleLabel.text = self.mediaItems.first?[indexPath.row].name
            loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: self.mediaItems.first?[indexPath.row].artwork.SongImageURL, imageView: cell.songImage)
            cell.addToPlaylistButton.tag = indexPath.row
//            cell.addToPlaylistButton.addTarget(self, action: #selector(didTapAddToPlaylist(_:)), for: .touchUpInside)
            cell.artistNameLbl.text = self.mediaItems.first?[indexPath.row].artistName
            if selected[indexPath.row]{
                cell.addToPlaylistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            }else {
                cell.addToPlaylistButton.setImage(UIImage(systemName: "Plus"), for: .normal)
            }
            cell.selectionStyle = .none
        }else{
            cell.songTitleLabel.text = "\(self.playlistArray[indexPath.row].value(forProperty: MPMediaPlaylistPropertyName)!)"
            if let artwork = self.playlistArray[indexPath.row].representativeItem?.artwork {
                let image = artwork.image(at: CGSize(width: 100, height: 100))
                cell.songImage.image = image
            }
            if selected[indexPath.row]{
                cell.addToPlaylistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            }else {
                cell.addToPlaylistButton.setImage(UIImage(systemName: "Plus"), for: .normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        
        if isSearching{
            cell.addToPlaylistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            selected[indexPath.row] = true
            let UD = Constants.staticKeys.USER_DEFAULTS.self
            guard let username = UD.value(forKey: Constants.UserDetails.UserName) as? String else { return }
            SocketIOManager.sharedInstance.searchForSongOverSocket(username: username, song: mediaItems[0][indexPath.row].identifier, songImage: mediaItems[0][indexPath.row].artwork.SongImageURL ?? "", type: "song", artistName: mediaItems[0][indexPath.row].artistName, name: mediaItems[0][indexPath.row].name, inviteCode:self.inviteCode) { data in
                print("add song in this room")
            }
        }else{
            guard let id = self.playlistArray[indexPath.row].value(forProperty: MPMediaPlaylistPropertyCloudGlobalID) as?  String else { return }
            APIManager().getPlaylistBy(id: id) { Data in
                let tracks = Data
                for single in tracks{
                    let singleDict = single as NSDictionary
                    guard let songName = singleDict.value(forKey: "name") as? String else { return }
                    guard let songtitle = singleDict.value(forKey: "trackID")as? String else { return }
                    guard let image = singleDict.value(forKey: "image") as? String else { return }
                    guard let artistName = singleDict.value(forKey: "artistName")as? String else { return }
                    guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return}
                    SocketIOManager.sharedInstance.searchForSongOverSocket(username: username, song: songtitle, songImage:image , type: "song", artistName: artistName, name:songName, inviteCode:self.inviteCode) { data in
                        print("add song in this room")
                    }
                }
                let alert = UIAlertController(title: "Success", message: "Your playlist added to the room.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } failure: { error in
                print(error)
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
    
}

