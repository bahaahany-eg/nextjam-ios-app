//
//  songTableViewCell.swift
//  musicPlayer
//
//  Created by apple on 19/08/21.
//

import UIKit

class songTableViewCell: UITableViewCell {

    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songImageView.layer.cornerRadius = 8
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
