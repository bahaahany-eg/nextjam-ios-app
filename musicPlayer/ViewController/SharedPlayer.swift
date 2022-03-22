//
//  SharedPlayer.swift
//  NextJAM
//
//  Created by Macintosh on 25/10/21.
//



extension Notification.Name {
    static let playNext = Notification.Name("PlayNext")
    static let playPrev = Notification.Name("PlayPrev")
}

import Foundation
import MediaPlayer
import AVKit
import AVFoundation


class SharedPlayer: NSObject{
    
    static let shared = SharedPlayer()
    
    var playerViewController: PlayerViewController?



    var timer: Timer?
    var isPaused: Bool!
    var appMediaPlayer = MPMusicPlayerController.applicationMusicPlayer
    var isBoolNextOneTime = true
    var invitation = ""
    var array = [SongDetails]()
    var currentSongIndex: Int?
    
    var StartOver = true
    var isComeFromBar: String = ""

    
    var currentSongJSON : SongDetails?

    
    fileprivate let imageLoader = ImageLoader.sharedInstance
    fileprivate var imageIndex : Int?
    

    // var to set in UI
    var currentSongURL: String = ""
    var currentSongName: String = ""
    var currentSongArtistName: String = ""
    

    
    override init() {
        super.init()
    }

}

extension SharedPlayer {
    
    func initilize() {

        appMediaPlayer.pause()
        self.playerViewController?.playerSlider.value = Float(0.0)

        
        appMediaPlayer.repeatMode = .default
        playerViewController?.playButton.tintColor = .white

        
        if let selectedIndex = currentSongIndex {
            currentSongIndex = selectedIndex
        } else {
            currentSongIndex = 0
        }
        


        isPaused = false
        playerViewController?.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
        //            self.array = sortSongs()
        let songInfo = array[currentSongIndex!]
        self.play(song: songInfo)

        
        playerViewController?.currentSongImage.layer.cornerRadius = 20
        playerViewController?.currentSongImage.clipsToBounds = true
        playerViewController?.currentSongImage.contentMode = .scaleAspectFill
        
        

        self.appMediaPlayer.shuffleMode = .off
        self.appMediaPlayer.repeatMode = .none
        
         // UIApplication.shared.endReceivingRemoteControlEvents()
         UIApplication.shared.beginReceivingRemoteControlEvents()
                
        setupTimer()

    }
    
    func play(song: SongDetails) {
        print("Song Id =>", song.songTitle)
        
        self.updateCurrentSongDetails(song: song)
        self.resetButtons()

        
        DispatchQueue.main.async {
            self.playerViewController?.seekLoadingLabel.alpha = 1
        }
        
        playS(id: song.songTitle, song: song)
        // self.emitNowPlaying(invitation: self.invitation, song_name: song.name)
        if currentSongIndex == 0 {
            DispatchQueue.main.async {
                self.playerViewController?.prevButton.isEnabled = false
                self.playerViewController?.prevButton.alpha = 0.2
            }
        }
    }
    
    func playS(id: String, song: SongDetails) {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.appMediaPlayer.pause()
            self.isPaused = true
            self.playerViewController?.playerSlider.value = Float(0.0)
            self.appMediaPlayer.nowPlayingItem = nil
            self.playerViewController?.timeLabel.text = "00:00"
            self.playerViewController?.currentTimeLabel.text = "00:00"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            self.appMediaPlayer.setQueue(with: [id])
            self.appMediaPlayer.currentPlaybackTime = 1


            self.appMediaPlayer.prepareToPlay { (error) in
                if (error != nil) {
                    print("[MUSIC PLAYER] Error preparing : \(String(describing: error))")
                } else {

                    self.setupTimer()
                    self.appMediaPlayer.play()
                    self.isBoolNextOneTime = true
                    self.playerViewController?.seekLoadingLabel.alpha = 0
                }
            }
            
        }
        

    }
    
    func resetButtons() {
        playerViewController?.playButton.loadingIndicator(false)

        
        DispatchQueue.main.async {
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
        if appMediaPlayer.playbackState == .playing  {
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"play.circle"), for: .normal)
            }
            appMediaPlayer.pause()
            isPaused = true

        } else {
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            }
            appMediaPlayer.play()
            isPaused = false

        }
    }
    
    func setupTimer() {
        self.timer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)

        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    func showLoader() {
        if(self.appMediaPlayer.playbackState == .stopped){
            DispatchQueue.main.async {
                self.playerViewController?.loadingLabel.isHidden = false
            }
        }else{
            DispatchQueue.main.async {
                self.playerViewController?.loadingLabel.isHidden = true
            }

        }
    }
    
    @objc func tick() {
        DispatchQueue.global(qos: .default).async {
            if self.appMediaPlayer.playbackState == .interrupted {
                DispatchQueue.main.async {
                    self.playerViewController?.playButton.setImage(UIImage(systemName:"play.circle"), for: .normal)
                    self.appMediaPlayer.pause()
                    self.isPaused = true
                    // self.timer?.invalidate()
                }
            } else {
                self.timerMethodToUpdateTheUI()
            }
        }
        
    }
    
    
    fileprivate func timerMethodToUpdateTheUI() {
//        DispatchQueue.global(qos: .background).async {
            
        print(Float(self.appMediaPlayer.currentPlaybackTime))
        
        
            self.showLoader()
            if(self.isPaused == false) {
                if(self.appMediaPlayer.nowPlayingItem?.rating == 0){
                    self.appMediaPlayer.play()
                    
                    
                    DispatchQueue.main.async {
                        self.playerViewController?.seekLoadingLabel.alpha = 0
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.playerViewController?.seekLoadingLabel.alpha = 0
                    }
                    
                }
            }
            if((self.appMediaPlayer.nowPlayingItem?.playbackDuration) != nil){
                
                guard let Duration  = self.appMediaPlayer.nowPlayingItem?.playbackDuration else { return }
                
                DispatchQueue.main.async {
                    self.playerViewController?.playerSlider.minimumValue = 0
                    self.playerViewController?.playerSlider.maximumValue = Float(Duration)
                    
                    self.playerViewController?.playerSlider.value = Float(self.appMediaPlayer.currentPlaybackTime)
                    
                    self.playerViewController?.timeLabel.text =  self.formatTimeFromSeconds(totalSeconds: Int32(Duration))
                    
                    self.playerViewController?.currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(self.appMediaPlayer.currentPlaybackTime))
                }
                
            }else{
                
                DispatchQueue.main.async {
                    self.playerViewController?.playerSlider.value = 0
                    self.playerViewController?.playerSlider.minimumValue = 0
                    self.playerViewController?.playerSlider.maximumValue = 0
                    self.playerViewController?.timeLabel.text = "Live stream \(self.formatTimeFromSeconds(totalSeconds: Int32(self.appMediaPlayer.currentPlaybackTime)))"
                }
                
                
                
            }
            
        autoNextAfterEndingSong()
            
//        }
    }
    
    fileprivate func autoNextAfterEndingSong() {
        // Auto next song after one second
        if self.isBoolNextOneTime {
            if let Duration = self.appMediaPlayer.nowPlayingItem?.playbackDuration {
                
                print("Total => ", Duration)
                print("Current => ", self.appMediaPlayer.currentPlaybackTime.rounded())
                
                DispatchQueue.main.async {
                    
                    
                    if self.playerViewController?.currentTimeLabel.text != "00:00" {
                        if Duration.rounded() == self.appMediaPlayer.currentPlaybackTime.rounded() {
                            self.timer?.invalidate()
                            do { sleep(3); self.isBoolNextOneTime = false; self.nextTrack(); }
                        }
                    }
                }
                
            }
        }
    }
    
    func nextTrack() {
        if(currentSongIndex! < self.array.count-1){
            currentSongIndex = currentSongIndex! + 1
            self.isPaused = false
            
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            }
            
            currentSongIndex = currentSongIndex!
            let songInfo = self.array[currentSongIndex!]
            DispatchQueue.main.async {
                self.playerViewController?.songNameLBL.text = songInfo.name
            }
            self.updateCurrentSongDetails(song: songInfo)
            self.play(song: songInfo)
            

            // self.emitNowPlaying(invitation: self.invitation, song_name: songInfo.name)
        } else {
            currentSongIndex = 0
            self.isPaused = false

            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            }

            currentSongIndex = currentSongIndex!
            let songInfo = self.array[currentSongIndex!]
            self.updateCurrentSongDetails(song: songInfo)
            self.play(song: songInfo)
            // self.emitNowPlaying(invitation: self.invitation, song_name: songInfo.name)
        }
        
    }
    
    func prevTrack(){
        //        self.array = sortSongs()
        if(currentSongIndex! > 0){
            currentSongIndex = currentSongIndex! - 1
            isPaused = false
            DispatchQueue.main.async {
                self.playerViewController?.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            }

            currentSongIndex = currentSongIndex!
            let songInfo = self.array[currentSongIndex!]
            self.updateCurrentSongDetails(song: songInfo)
            self.play(song: songInfo)
            // self.emitNowPlaying(invitation: self.invitation, song_name: songInfo.name)
        }

        DisableBtnInZeroIndex()
    }
    
    func DisableBtnInZeroIndex()  {
        if (currentSongIndex == 0 ){
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
        setCurrentSongImage()
    }
    
    func setCurrentSongImage() {

        DispatchQueue.main.async {
            self.playerViewController?.songNameLBL.text = self.currentSongName
            self.playerViewController?.artistNameLbl.text = self.currentSongArtistName
            self.loadImage(defaultImage: UIImage(named: "NextJamLogo"), url: self.currentSongURL , imageView: self.playerViewController?.currentSongImage)
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
        playerViewController?.playButton.loadingIndicator(true)
        playerViewController?.playButton.alpha = 0.2
        playerViewController?.nextButton.isEnabled = false
        playerViewController?.prevButton.isEnabled = false
        playerViewController?.nextButton.alpha = 0.2
        playerViewController?.prevButton.alpha = 0.2
        self.nextTrack()
    }
    
    func prevButtonClicked(_ sender: Any) {
        playerViewController?.playButton.loadingIndicator(true)
        playerViewController?.playButton.alpha = 0.2
        playerViewController?.nextButton.isEnabled = false
        playerViewController?.prevButton.isEnabled = false
        playerViewController?.nextButton.alpha = 0.2
        playerViewController?.prevButton.alpha = 0.2
        self.prevTrack()
    }
    
    func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        self.appMediaPlayer.currentPlaybackTime = TimeInterval(seconds)
        if(self.isPaused == false){
            playerViewController?.seekLoadingLabel.alpha = 0
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
            
            print(seconds)
            
            self.appMediaPlayer.currentPlaybackTime = TimeInterval(seconds)
            if(self.isPaused == false){
                playerViewController?.seekLoadingLabel.alpha = 0
            }
        }
    }


}
