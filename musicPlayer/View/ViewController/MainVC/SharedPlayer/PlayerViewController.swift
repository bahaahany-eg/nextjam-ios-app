//
//  PlayerViewController.swift
//  musicPlayer
//
//  Created by Macintosh on 14/10/21.
//

import UIKit
import MediaPlayer
import AVFAudio

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var seekLoadingLabel: UILabel!
    @IBOutlet var songNameLBL: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var currentSongImage: UIImageView!
    
    var isComeFrom : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedPlayer.shared.playerViewController = self

        if isComeFrom == "PlaySong" {
            SharedPlayer.shared.initilize()
        } else {
            SharedPlayer.shared.setCurrentSongImage()
            SharedPlayer.shared.DisableBtnInZeroIndex()
            if SharedPlayer.shared.appMediaPlayer.playbackState == .playing  {
                self.playButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            } else {
                self.playButton.setImage(UIImage(systemName:"play.circle"), for: .normal)
            }
        }
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        SharedPlayer.shared.playButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        SharedPlayer.shared.nextButtonClicked(sender)
    }

    @IBAction func prevButtonClicked(_ sender: Any) {
        SharedPlayer.shared.prevButtonClicked(sender)
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        SharedPlayer.shared.sliderValueChange(sender)
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        SharedPlayer.shared.sliderTapped(sender)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Emit now Playing Song to Socket
    func emitNowPlaying(invitation: String,song_name: String){
        SocketIOManager.sharedInstance.updateNowPlayingSongs(inviteCode: invitation, songName: song_name) { updateResponse in
            print("event emitted")
        }
    }
    
}
