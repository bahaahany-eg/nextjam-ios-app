//
//  SharedPlayer.swift
//  NextJAM
//
//  Created by Macintosh on 25/10/21.
//

import Foundation
import MediaPlayer
import AVKit
import AVFoundation

final class SharedPlayer {
    
    static var shared = SharedPlayer()
    
    // var playerViewController: PlayerViewController?
    
    var playerViewController: PlayerView?

    weak var appMediaPlayer = MPMusicPlayerController.applicationQueuePlayer
    var catalogQueueDescriptor: MPMusicPlayerStoreQueueDescriptor?

    var currentSongId: String?
    
    var playOne = false
    var isNotify = false
    
    var isNotifyWhenActive = true
    

    
    var timer: Timer? = nil
    var isPaused: Bool!


    var isBoolNextOneTime = true
    var invitation = ""
    // var array = [SongDetails]()
    var array: [SongDetails]? = []
    var currentSongIndex: Int?
            
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    
    // var to set in UI
    var currentSongURL: String = ""
    var currentSongName: String = ""
    var currentSongArtistName: String = ""
    

    var currentTime: Int32?
    var totalTime: Int32?
    var progressBarValue: Float?
    

    init() {
  
    }

}

extension SharedPlayer {
    
    func initilize() {
        var SongId: [String] = []
        self.array?.forEach({ s in
            SongId.append(s.songTitle)
        })
        
        appMediaPlayer = MPMusicPlayerController.applicationQueuePlayer
        self.catalogQueueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: SongId)
        
        appMediaPlayer?.pause()
        self.playerViewController?.playerSlider.value = Float(0.0)
        
        appMediaPlayer?.repeatMode = .default
        
        playerViewController?.playButton.tintColor = .white
        
        if let selectedIndex = currentSongIndex {
            currentSongIndex = selectedIndex
        } else {
            currentSongIndex = 0
        }
        
        isPaused = false
        playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
        //            self.array = sortSongs()
        guard let songInfo = array?[currentSongIndex!] else { return }
        self.play(song: songInfo)
        
//        playerViewController?.currentSongImage.layer.cornerRadius = 20
//        playerViewController?.currentSongImage.clipsToBounds = true
//        playerViewController?.currentSongImage.contentMode = .scaleAspectFill
        
        
        // self.appMediaPlayer?.shuffleMode = .
        self.appMediaPlayer?.repeatMode = .default
        
         // UIApplication.shared.endReceivingRemoteControlEvents()
         UIApplication.shared.beginReceivingRemoteControlEvents()
                        
        NotificationCenter.default.addObserver(self, selector: #selector(self.nowPlayingItemDidChange(sender:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        self.playerViewController?.playButton.tintColor = .black
        
    }
    
    func changeBoolStatus() {
        isNotifyWhenActive = false
        let seconds = 7.0
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            self.isNotifyWhenActive = true
        }

    }
    
    @objc func nowPlayingItemDidChange(sender: Notification) {
        if isNotify {
             SocketIOManager.sharedInstance.establishConnection()
            self.emitNowPlaying(invitation: self.invitation, song_name: self.appMediaPlayer?.nowPlayingItem?.title ?? "", id: self.appMediaPlayer?.nowPlayingItem?.playbackStoreID ?? "")
        }
        
        if isNotifyWhenActive {
            SocketIOManager.sharedInstance.establishConnection()
           self.emitNowPlaying(invitation: self.invitation, song_name: self.appMediaPlayer?.nowPlayingItem?.title ?? "", id: self.appMediaPlayer?.nowPlayingItem?.playbackStoreID ?? "")
            
            changeBoolStatus()
        }
        
        if playOne {
            if self.appMediaPlayer?.playbackState != .stopped  {
                if let time = self.appMediaPlayer?.currentPlaybackTime {
                    if time != 0 ||  time != 1 ||  time != 2 ||  time != 3 {
                        nextTrack()
                        playOne = false
                    }
                }
            }
        }
        
        guard let songList = array, let currentIndex = self.appMediaPlayer?.indexOfNowPlayingItem else { return }

        if currentIndex < songList.count { currentSongIndex = currentIndex }
        
        currentSongName = self.appMediaPlayer?.nowPlayingItem?.title ?? "" // song.name
        currentSongArtistName = self.appMediaPlayer?.nowPlayingItem?.artist ?? "" // song.artistName
        
        if let index = currentSongIndex {
            if songList.count > index {
                currentSongURL = songList[index].songImage
            }
        }
        
        DispatchQueue.main.async {
            // self.playerViewController?.updateAllUI()
            self.playerViewController?.updateAllUI()
            
        }
        
        let seconds = 2.0
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            self.DisableBtnInZeroIndex()
            self.resetButtons()

            if self.appMediaPlayer?.playbackState == .playing {
                DispatchQueue.main.async {
                    self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.playerViewController?.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
                }
            }
        }

    }
    

    func play(song: SongDetails) {
        print("Song Id =>", song.songTitle)
        
        self.updateCurrentSongDetails(song: song)
        self.resetButtons()
        
        DispatchQueue.main.async {
//            self.playerViewController?.seekLoadingLabel.alpha = 1
        }
        
        playS(id: song.songTitle, song: song)
                
        if currentSongIndex == 0 {
            DispatchQueue.main.async {
                self.playerViewController?.prevButton.isEnabled = false
                self.playerViewController?.prevButton.alpha = 0.2
            }
        }
    }
    
    func playS(id: String, song: SongDetails) {
        currentSongId = id
        var SongId: [String] = []
        array?.forEach({ s in
            SongId.append(s.songTitle)
        })
        
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.setupTimer()
            self.appMediaPlayer?.pause()
            self.isPaused = true
            self.playerViewController?.playerSlider.value = Float(0.0)
            self.appMediaPlayer?.nowPlayingItem = nil
            self.playerViewController?.timeLabel.text = "00:00"
            self.playerViewController?.currentTimeLabel.text = "00:00"
        }
        
        SharedPlayer.shared.appMediaPlayer?.currentPlaybackTime = 0
        

        DispatchQueue.global().asyncAfter(deadline: .now() + 0) {
            
            guard let catalogQueue = self.catalogQueueDescriptor else { return  }
            // let catalogQueue = MPMusicPlayerStoreQueueDescriptor(storeIDs: SongId)
            catalogQueue.storeIDs = SongId

            
            catalogQueue.startItemID = self.currentSongId
            self.appMediaPlayer?.setQueue(with: catalogQueue)
            

            self.appMediaPlayer?.currentPlaybackTime = 1
            self.appMediaPlayer?.prepareToPlay { (error) in
                if (error != nil) {
                    print("[MUSIC PLAYER] Error preparing : \(String(describing: error))")
                } else {
                    self.appMediaPlayer?.play()
                    self.isBoolNextOneTime = true
//                    self.playerViewController?.seekLoadingLabel.alpha = 0
                    
                    self.emitNowPlaying(invitation: self.invitation, song_name: self.appMediaPlayer?.nowPlayingItem?.title ?? "", id: self.appMediaPlayer?.nowPlayingItem?.playbackStoreID ?? "")
                    
                    self.DisableBtnInZeroIndex()
                    self.resetButtons()

                }
            }

        }

        
        
        
    }
    
    //MARK: - Emit now Playing Song to Socket
    func emitNowPlaying(invitation: String,song_name: String, id: String){
        print("Calling Socket")
        
        print("Song Id => ", id)
        print("invitation Id => ", invitation)
        print("Song Name => ", song_name)

        
        SocketIOManager.sharedInstance.updateNowPlayingSongs(songID: id, inviteCode: invitation, songName: song_name) { updateResponse in
            print("event emitted")
//            self.timer?.invalidate()
//            self.setupTimer()
        }
        
    }
    
    func resetButtons() {
        DispatchQueue.main.async {
            self.playerViewController?.playButton.loadingIndicator(false)
            self.playerViewController?.playButton.alpha = 1
            self.playerViewController?.nextButton.alpha = 1
            self.playerViewController?.nextButton.isEnabled = true
            
            if self.currentSongIndex != 0 {
                self.playerViewController?.prevButton.isEnabled = true
                self.playerViewController?.prevButton.alpha = 1
            }
        }
    }
    
    
    
    func togglePlayPause() {
        if appMediaPlayer?.playbackState == .playing  {
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
            }
            appMediaPlayer?.pause()
            isPaused = true
//            timer?.invalidate()
        } else {
            DispatchQueue.main.async {
//                self.timer?.invalidate()
//                self.setupTimer()
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
            }
            appMediaPlayer?.play()
            isPaused = false
        }
    }
    
    func setupTimer() {
        self.timer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    func showLoader() {
        if(self.appMediaPlayer?.playbackState == .stopped) {
            DispatchQueue.main.async {
//                self.playerViewController?.loadingLabel.isHidden = false
//                self.playerViewController?.seekLoadingLabel.alpha = 1
            }
        }else{
            DispatchQueue.main.async {
//                self.playerViewController?.seekLoadingLabel.alpha = 0
//                self.playerViewController?.loadingLabel.isHidden = true
            }
        }
    }
    
    @objc func tick() {
        self.showLoader()
        DispatchQueue.global(qos: .default).async {
            if self.appMediaPlayer?.playbackState == .interrupted {
                DispatchQueue.main.async {
                    self.playerViewController?.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
                    self.appMediaPlayer?.pause()
                    self.isPaused = true
                    // self.timer?.invalidate()
                }
            } else {
                self.timerMethodToUpdateTheUI()
            }
        }
        
    }
    
    fileprivate func timerMethodToUpdateTheUI() {
            if(self.isPaused == false) {
                if(self.appMediaPlayer?.nowPlayingItem?.rating == 0){
                   // self.appMediaPlayer.play()
                    DispatchQueue.main.async {
//                        self.playerViewController?.seekLoadingLabel.alpha = 0
                    }
                }else{
                    DispatchQueue.main.async {
//                        self.playerViewController?.seekLoadingLabel.alpha = 0
                    }
                    
                }
            }


//        if self.appMediaPlayer?.playbackState == .playing {
//            DispatchQueue.main.async {
//                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.playerViewController?.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
//            }
//        }
        
                        
        if self.appMediaPlayer?.playbackState == .playing || self.appMediaPlayer?.playbackState == .paused {

                
            guard let Duration  = self.appMediaPlayer?.nowPlayingItem?.playbackDuration else { return }
                
                DispatchQueue.main.async {
                    self.playerViewController?.playerSlider.minimumValue = 0
                    self.playerViewController?.playerSlider.maximumValue = Float(Duration)
                    
                    self.playerViewController?.playerSlider.value = Float(self.appMediaPlayer?.currentPlaybackTime ?? 0)
                    
                    let val = Float(Duration) - Float(self.appMediaPlayer?.currentPlaybackTime ?? 0)
                    self.playerViewController?.timeLabel.text =  "-\(self.formatTimeFromSeconds(totalSeconds: Int32(val)))"
                    
                    self.playerViewController?.currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(self.appMediaPlayer?.currentPlaybackTime ?? 0))
                    

                    if let time = self.appMediaPlayer?.currentPlaybackTime {
                        UserDefaults.standard.set(Int64(time), forKey: "PlaybackDuration")
                    }
                    print("Playing time", UserDefaults.standard.value(forKey: "PlaybackDuration"))
                    
                    print("remaining time:",val)
                    if val <= 1{
                        self.nextTrack()
                    }

                }
                
            } else {
                DispatchQueue.main.async {
                    self.playerViewController?.playerSlider.value = 0
                    self.playerViewController?.playerSlider.minimumValue = 0
                    self.playerViewController?.playerSlider.maximumValue = 0
                    self.playerViewController?.timeLabel.text = "Live stream"
                }
                
            }
    }
    
    
//    func GetAndUpdateNowPlaying(songID:String){
//        self.array?.forEach({ s in
//            if s.songTitle == songID {
//                self.updateCurrentSongDetails(song: s)
//                self.emitNowPlaying(invitation: self.invitation, song_name: s.name, id: s.songTitle)
//            }
//        })
//
//    }
//
//    func PREVTRACK(){
//        self.appMediaPlayer?.skipToPreviousItem()
//        guard let id = self.appMediaPlayer?.nowPlayingItem?.playbackStoreID else { return }
//        self.GetAndUpdateNowPlaying(songID:id)
//    }
//    func NEXTTRACK(){
//        self.appMediaPlayer?.skipToNextItem()
//        guard let id = self.appMediaPlayer?.nowPlayingItem?.playbackStoreID else { return }
//        self.GetAndUpdateNowPlaying(songID:id)
//    }
    
    func nextTrack() {
        guard let array = array else { return }
        if(currentSongIndex! < array.count-1){
            currentSongIndex = currentSongIndex! + 1
            self.isPaused = false

            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
            }

            currentSongIndex = currentSongIndex!
            let songInfo = array[currentSongIndex!]
            DispatchQueue.main.async {
//                self.playerViewController?.songNameLBL.text = songInfo.name
            }
            self.updateCurrentSongDetails(song: songInfo)
            self.play(song: songInfo)

        } else {
            currentSongIndex = 0
            self.isPaused = false
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
            }
            currentSongIndex = currentSongIndex!
            if let songInfo = self.array?[currentSongIndex!] {
                self.updateCurrentSongDetails(song: songInfo)
                self.play(song: songInfo)
            }
        }

    }
    
    func prevTrack(){
        if(currentSongIndex! > 0){
            currentSongIndex = currentSongIndex! - 1
            isPaused = false
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
            }
            currentSongIndex = currentSongIndex!
            if let songInfo = self.array?[currentSongIndex!] {
                self.updateCurrentSongDetails(song: songInfo)
                self.play(song: songInfo)
            }
        }
    }
    
    func DisableBtnInZeroIndex() {
        if (currentSongIndex == 0) {
            DispatchQueue.main.async {
                self.playerViewController?.prevButton.isEnabled = false
                self.playerViewController?.prevButton.alpha = 0.5
            }
        }
    }
    
    func updateCurrentSongDetails(song:SongDetails){
        currentSongName = song.name
        currentSongArtistName = song.artistName
        currentSongURL = song.songImage
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
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        // let hours: Int32 = totalSeconds/3600
        // return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
        return String(format: "%02d:%02d", minutes,seconds)
    }
}


extension SharedPlayer {
    
    func playButtonClicked(_ sender: Any) {
        self.togglePlayPause()
    }
    
    func nextButtonClicked(_ sender: Any) {
//        DispatchQueue.main.async {
//            self.playerViewController?.playButton.loadingIndicator(true)
//            self.playerViewController?.playButton.alpha = 0.2
//            self.playerViewController?.nextButton.isEnabled = false
//            self.playerViewController?.prevButton.isEnabled = false
//            self.playerViewController?.nextButton.alpha = 0.2
//            self.playerViewController?.prevButton.alpha = 0.2
//        }
        self.nextTrack()
    }
    
    func prevButtonClicked(_ sender: Any) {
//        DispatchQueue.main.async {
//            self.playerViewController?.playButton.loadingIndicator(true)
//            self.playerViewController?.playButton.alpha = 0.2
//            self.playerViewController?.nextButton.isEnabled = false
//            self.playerViewController?.prevButton.isEnabled = false
//            self.playerViewController?.nextButton.alpha = 0.2
//            self.playerViewController?.prevButton.alpha = 0.2
//        }
//        self.prevTrack()
        self.prevTrack()
    }
    
    func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        self.appMediaPlayer?.currentPlaybackTime = TimeInterval(seconds)
        if(self.isPaused == false){
//            playerViewController?.seekLoadingLabel.alpha = 0
        }
    }
    
    func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            
//            DispatchQueue.main.async {
                self.appMediaPlayer?.currentPlaybackTime = TimeInterval(seconds)
//            }
            
            if(self.isPaused == false){
                DispatchQueue.main.async {
//                    self.playerViewController?.seekLoadingLabel.alpha = 0
                }
            }
        }
    }
}
