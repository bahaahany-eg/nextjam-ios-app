//
//  FollowFavouritePeopleTableViewCell.swift
//  NextJAM
//
//  Created by apple on 06/09/21.
//

import UIKit

class FollowFavouritePeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followBtnAction(_ sender: Any) {
    
    }
}
