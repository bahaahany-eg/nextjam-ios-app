//
//  RoomPlayListCell.swift
//  NextJAM
//
//  Created by apple on 16/09/21.
//

import UIKit

class RoomPlayListCell: UITableViewCell {

    @IBOutlet weak var UserAddingSngImg: CustomImageView!
    @IBOutlet weak var userAddingSngName: UILabel!
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumImage: CustomImageView!
    @IBOutlet weak var dltBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
//    ButtonAction Closure
    var menuPressed : (()->()) = {}
    
    @IBAction func menuBtn(_ sender: UIButton){
        sender.showsMenuAsPrimaryAction = true
        menuPressed()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
