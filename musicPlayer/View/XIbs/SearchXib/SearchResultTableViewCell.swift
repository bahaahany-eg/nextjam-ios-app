//
//  SearchResultTableViewCell.swift
//  NextJAM
//
//  Created by Abhishek Mahajan on 23/08/21.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    //MARK: - Outlet
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var artistNameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
