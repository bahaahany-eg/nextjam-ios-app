//
//  LikedSongCell.swift
//  NextJAM
//
//  Created by apple on 23/11/21.
//

import UIKit

class LikedSongCell: UITableViewCell {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
