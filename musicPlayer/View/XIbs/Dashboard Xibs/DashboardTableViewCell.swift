//
//  DashboardTableViewCell.swift
//  musicPlayer
//
//  Created by Abhishek Mahajan on 19/08/21.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    //MARK: - Outlet
    @IBOutlet weak var eventNameView: UIView!
    @IBOutlet weak var moveForwardButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventNameView.layer.cornerRadius = 12
        moveForwardButton.layer.cornerRadius = moveForwardButton.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
