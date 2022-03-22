//
//  InvitationCell.swift
//  NextJAM
//
//  Created by apple on 25/11/21.
//

import UIKit

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var img: CustomImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var resend: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
