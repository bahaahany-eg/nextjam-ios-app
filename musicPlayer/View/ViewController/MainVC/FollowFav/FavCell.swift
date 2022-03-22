//
//  FavCell.swift
//  NextJAM
//
//  Created by apple on 14/09/21.
//

import UIKit

class FavCell: UITableViewCell {

    
    
    @IBOutlet weak var Display_name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userImage: CustomImageView!
    @IBOutlet weak var followerCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

