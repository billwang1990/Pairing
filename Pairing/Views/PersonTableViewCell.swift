//
//  PersonTableViewCell.swift
//  Pairing
//
//  Created by Yaqing Wang on 29/09/2017.
//  Copyright © 2017 Yaqing Wang. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var personName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
