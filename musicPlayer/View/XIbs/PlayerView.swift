//
//  PlayerView.swift
//  NextJAM
//
//  Created by Macintosh on 03/01/22.
//

import UIKit

extension UIView {
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self))
            .loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
                return nil
        }
        return contentView
    }
}


protocol barPlayerViewProtocal {
    func playButtonClicked(_ sender: Any)
    func nextButtonClicked(_ sender: Any)
    func prevButtonClicked(_ sender: Any)
    func sliderValueChange(_ sender: UISlider)
    func sliderTapped(_ sender: UILongPressGestureRecognizer)
    
    func addNewSongAction()
    
    func updateCurrentSong()
}

class PlayerView: UIView {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    var delegate: barPlayerViewProtocal?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    // MARK: - Loading the xib
    private func load() {
        guard let contentView = self.fromNib()
            else { fatalError("View could not load from nib") }
        contentView.frame = self.bounds
        contentView.clipsToBounds = true
        addSubview(contentView)
        SharedPlayer.shared.playerViewController = self
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        delegate?.playButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        delegate?.nextButtonClicked(sender)
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        delegate?.prevButtonClicked(sender)
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        delegate?.sliderValueChange(sender)
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        delegate?.sliderTapped(sender)
    }
    
    
    @IBAction func addNewSongBtnAction(_ sender: UIButton) {
        delegate?.addNewSongAction()
    }
    
    func updateAllUI() {
         delegate?.updateCurrentSong()
    }
    
}
