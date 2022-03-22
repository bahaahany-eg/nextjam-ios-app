//
//  PlayerViewController.swift
//  musicPlayer
//
//  Created by Macintosh on 14/10/21.
//

import UIKit
import MediaPlayer

import AVFAudio

protocol UpdateCurrentSong {

    // func updateCurrentSong()
}


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
    
    var delegate: UpdateCurrentSong?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initilize()
    }
    
    fileprivate func initilize() {
//        SharedPlayer.shared.playerViewController = self

        if isComeFrom == "PlaySong" {
            SharedPlayer.shared.initilize()
        } else {
            updateAllUI()
//            SharedPlayer.shared.setCurrentSongImage()
            SharedPlayer.shared.DisableBtnInZeroIndex()
            if SharedPlayer.shared.appMediaPlayer?.playbackState == .playing  {
                self.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
                seekLoadingLabel.isHidden = true
            } else {
                SharedPlayer.shared.timer?.invalidate()
                SharedPlayer.shared.setupTimer()
                self.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
            }
        }
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.playButtonClicked(sender)
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.nextButtonClicked(sender)
        }
    }
    
    func updateAllUI() {

        // delegate?.updateCurrentSong()

    }

    @IBAction func prevButtonClicked(_ sender: Any) {
        DispatchQueue.global(qos: .default).async {
            SharedPlayer.shared.prevButtonClicked(sender)
        }
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        SharedPlayer.shared.sliderValueChange(sender)
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        SharedPlayer.shared.sliderTapped(sender)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
