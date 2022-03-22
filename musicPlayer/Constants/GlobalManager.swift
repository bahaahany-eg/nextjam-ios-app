//
//  GlobalManager.swift
//  GlobalManager
//
//  Created by apple on 28/09/21.
//

import Foundation
import MediaPlayer


class GlobalManager {
    

    static let shared = GlobalManager()
    
    let userDefaults = Constants.staticString.USER_DEFAULTS.self
    var SongsArray : [SongDetails] = []
    var index: Int?
    // let Player = MPMusicPlayerController.applicationMusicPlayer
    
    private init(){}

    func getArray()->[SongDetails]{
        return SongsArray
    }

    func addDataInArray(data : [SongDetails]){
        SongsArray = data
    }
    func addSinglesToArray(data: SongDetails){
        SongsArray.append(data)
    }
    func removeSongs() {
        SongsArray.removeAll()
    }
}

//MARK: - Global Manager Extension For Music Player
//extension GlobalManager {
//    
//    func skipToNext(){
//        Player.skipToNextItem()
//    }
//    func skipToPrevious(){
//        Player.skipToPreviousItem()
//    }
//    func playPause(play:Bool){
//        switch play {
//        case true:
//            Player.play()
//            return
//        case false:
//            Player.pause()
//            return
//        }
//    }
//    //MARK: - Play song with songID
//    func playByStoreID( storeIds:[String]) {
//        DispatchQueue.main.async {
//            
//            if #available(iOS 10.1, *) {
//                let descriptor:MPMusicPlayerStoreQueueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIds)
//                self.Player.setQueue(with: descriptor)
//                self.Player.prepareToPlay { (error) in
//                    if (error != nil) {
//                        print(error!)
//                    }else {
//                        self.Player.play()
//                    }
//                }
//            }else {
//                self.Player.setQueue(with: storeIds)
//                self.Player.play()
//                
//            }
//        }
//        
//    }
//}

//MARK: - Global Manager Extension for handling UserDefaults
extension GlobalManager {
    
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    
}
