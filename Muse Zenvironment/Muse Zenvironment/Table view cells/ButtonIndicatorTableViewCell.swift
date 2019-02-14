//
//  ButtonIndicatorTableViewCell.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 2/12/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import UIKit

class ButtonIndicatorTableViewCell: UITableViewCell {
    @IBOutlet weak var buttonTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
