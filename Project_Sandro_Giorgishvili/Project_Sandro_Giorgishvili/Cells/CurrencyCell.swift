//
//  CurrencyCell.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 04.09.22.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var currencyNameInGEOLbl: UILabel!
    @IBOutlet weak var currencyShortNameLbl: UILabel!
    @IBOutlet weak var currencyAmountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
