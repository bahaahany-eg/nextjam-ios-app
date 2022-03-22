//
//  FeedCell.swift
//  NextJAM
//
//  Created by apple on 08/09/21.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var mainImage: UIView!
    @IBOutlet weak var AlbumImage: UIImageView!
    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var currentPlayingLbl: UILabel!
    
    @IBOutlet weak var detailView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
