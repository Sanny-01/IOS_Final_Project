//
//  ProfileSettingsCell.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 08.09.22.
//

import UIKit

class ProfileSettingsCell: UITableViewCell {

    @IBOutlet weak var settingNameLbl: UILabel!
    @IBOutlet weak var settingIconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
