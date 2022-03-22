//
//  RoomPlayListAdapter.swift
//  NextJAM
//
//  Created by Macintosh on 07/01/22.
//

import Foundation
import UIKit


extension RoomPlayListVC {
    
    func setCurrentPlayingSongInfoGuestSide(information: SongDetails) {
        songPlayingUsersImg.isHidden = false
        songPlayingUsersName.isHidden = false
        heartBtn.isHidden = false
        
        let info = information.userData

        songPlayingUsersImg.image = UIImage(named: "NextJamLogo")
        
        songPlayingUsersImg.kf.indicatorType = .activity
        songPlayingUsersImg.kf.setImage(with: URL(string: info.profileImage), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)

        songPlayingUsersName.text = info.username.capitalized
        
        // Setup like and unlike
        let infoList = self.liked.filter { l in l.songTitle == information.songTitle }
        infoList.count != 0 ? heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal) : heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        getLikedSongs()
//        self.fetchSongfromServer()
    }
    
    func setCurrentPlayingSongInfo() {
        guard let list = SharedPlayer.shared.array,
              let indx = SharedPlayer.shared.currentSongIndex else { return }
        
        DispatchQueue.main.async {
            self.songPlayingUsersImg.isHidden = false
            self.songPlayingUsersName.isHidden = false
            self.heartBtn.isHidden = false
        }
        
        
        let info = list.filter { SongDetails in SongDetails.songTitle == list[indx].songTitle }
        
        if let imgURL = info.first?.userData.profileImage {
            songPlayingUsersImg.kf.indicatorType = .activity
            songPlayingUsersImg.kf.setImage(with: URL(string: imgURL), placeholder: UIImage(named: "NextJamLogo"), options: [.transition(.fade(0.7))], progressBlock: nil)
        } else {
            songPlayingUsersImg.image = UIImage(named: "NextJamLogo")
        }
        songPlayingUsersName.text = info.first?.userData.username.capitalized
        
        
        // Setup like and unlike
        let infoList  = self.liked.filter { l in l.songTitle == list[indx].songTitle }
        infoList.count != 0 ? heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal) : heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        getLikedSongs()
        self.fetchSongfromServer()
    }
    
    func nowPlayingLikeAction(forHostInfo: [SongDetails]?, forGuestInfo: SongDetails?) {
        
        if let hostInfo = forHostInfo?.first  {
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{ return }

            let params = ["artist_name": hostInfo.artistName,
                          "song_title": hostInfo.songTitle,
                          "image_url": hostInfo.songImage,
                          "name": hostInfo.name]
            
            DispatchQueue.main.async {
                self.heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }

            WebLayerUserAPI().LikeSongs(params: params, username: username) { data in
                print("================\nSong liked\n=================")
                self.fetchSongfromServer()
                
                // self.setupLikeButton()
            } failure: { error in
                print(error)
            }
            
            self.fetchSongfromServer()
        }
        
        if let guestInfo = forGuestInfo  {
            guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else{ return }

            let params = ["artist_name": guestInfo.artistName,
                          "song_title": guestInfo.songTitle,
                          "image_url": guestInfo.songImage,
                          "name": guestInfo.name]
            
            DispatchQueue.main.async {
                self.heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            
            WebLayerUserAPI().LikeSongs(params: params, username: username) { data in
                print("================\nSong liked\n=================")
                self.fetchSongfromServer()
                                           
                // self.setupLikeButton()
            } failure: { error in
                print(error)
            }
            
            self.fetchSongfromServer()
        }
        
    }
    
    func nowPlayingUnLikeBtnAction(forHostInfo: [SongDetails]?, forGuestInfo: SongDetails?) {
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }

        if let hostInfo = forHostInfo?.first {
            WebLayerUserAPI().unlikeSong(with: Int(hostInfo.songTitle)!, username: username) { data in
                print("===============\n\(data)\n============")
                self.fetchSongfromServer()
                
                DispatchQueue.main.async {
                    self.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                
                self.fetchSongfromServer()
                                           
                // self.setupLikeButton()
            } failure: { error in
                print(error)
            }
        }
        
        if let guestInfo = forGuestInfo {
            WebLayerUserAPI().unlikeSong(with: Int(guestInfo.songTitle)!, username: username) { data in
                print("===============\n\(data)\n============")
                self.fetchSongfromServer()

                DispatchQueue.main.async {
                    self.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                   
                self.fetchSongfromServer()
                
                // self.setupLikeButton()
            } failure: { error in
                print(error)
            }
        }
        
    }

}


extension RoomPlayListVC: barPlayerViewProtocal {
    
    func playButtonClicked(_ sender: Any) {
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.playButtonClicked(sender)
        }
    }
    
    func nextButtonClicked(_ sender: Any) {

        self.nowPlayingTitle.forEach { lbl in
            lbl.text = "Not Playing"
        }
        self.nowPlayingImage.forEach { imgView in
            imgView.image =  UIImage(named: "NextJamLogo")
        }
        self.nowplayingArtist.forEach { arLbl in
            arLbl.text = ""
        }
        
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.nextButtonClicked(sender)
        }
        SharedPlayer.shared.changeBoolStatus()
        
        
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.setCurrentPlayingSongInfo()
        }
    }
    
    func prevButtonClicked(_ sender: Any) {
        
        self.nowPlayingTitle.forEach { lbl in
            lbl.text = "Not Playing"
        }
        self.nowPlayingImage.forEach { imgView in
            imgView.image =  UIImage(named: "NextJamLogo")
        }
        self.nowplayingArtist.forEach { arLbl in
            arLbl.text = ""
        }
        
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.prevButtonClicked(sender)
        }
        SharedPlayer.shared.changeBoolStatus()
        
        
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.setCurrentPlayingSongInfo()
        }
    }
    
    func sliderValueChange(_ sender: UISlider) {
        SharedPlayer.shared.sliderValueChange(sender)
    }
    
    func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        SharedPlayer.shared.sliderTapped(sender)
    }
    
    func addNewSongAction() {
        self.addSongsAction()
    }
    
}
