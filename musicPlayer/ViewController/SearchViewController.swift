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

class SearchVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var searchMusicSearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    //MARK:- Variable
    var mediaItems = [[MediaItem]]()
    var mediaPlaylist: MPMediaPlaylist!
    let playlistUUIDKey = "playlistUUIDKey"
    var playlistUUID = UUID()
    var userType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchMusicSearchBar.delegate = self
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        
        
        SKCloudServiceController.requestAuthorization { (status) in
                    if status == .authorized {
                        self.createPlaylistIfNeeded()
                    }
                }
       
        
    }
    
    @IBAction func action_backbtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func createPlaylistIfNeeded() {
        
        guard mediaPlaylist == nil else { return }
        
       
       
        
        var playlistCreationMetadata: MPMediaPlaylistCreationMetadata!
        
        let userDefaults = UserDefaults.standard
        
//        if let playlistUUIDString = userDefaults.string(forKey: playlistUUIDKey) {
//
//            guard let uuid = UUID(uuidString: playlistUUIDString) else {
//                fatalError("Failed to create UUID from existing UUID string: \(playlistUUIDString)")
//            }
//
//            playlistUUID = uuid
//        } else {
//        }
           
           playlistUUID = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!
            
           
            playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: "NextJam Playlist")
            
            playlistCreationMetadata.descriptionText = "This playlist was created using \(Bundle.main.infoDictionary!["CFBundleName"]!) to demonstrate how to use the Apple Music APIs"
            
           
            userDefaults.setValue(playlistUUID.uuidString, forKey: playlistUUIDKey)
            userDefaults.synchronize()
//        }
       

        // Request the new or existing playlist from the device.
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
            guard error == nil else {
                fatalError("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
            }
            
            self.mediaPlaylist = playlist
          
            //NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        }
    }
    
    @objc func didTapAddToPlaylist(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        SocketIOManager.sharedInstance.searchForSongOverSocket(song: mediaItems[0][sender.tag].identifier, type: "song", artistName: mediaItems[0][sender.tag].artistName, name: mediaItems[0][sender.tag].name, inviteCode: Constants.staticString.USER_DEFAULTS.value(forKey: Constants.staticString.invitationCode) as! String) { data in
            print(data)
            print("add song in this room")
        }
    }
    
}

extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchString = searchBar.text else{
            return
        }
        
        APIManager().performAppleMusicCatalogSearch(with: searchString, countryCode: "us") { medias, error in
            guard error == nil else{
                return
            }
            
            self.mediaItems = medias
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.searchResultTableView.reloadData()
            }
             
        }
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediaItems.first?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else{
            return UITableViewCell.init()
        }
       
        cell.songTitleLabel.text = self.mediaItems.first?[indexPath.row].name
        
        cell.addToPlaylistButton.tag = indexPath.row
        
        cell.addToPlaylistButton.addTarget(self, action: #selector(didTapAddToPlaylist(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}

