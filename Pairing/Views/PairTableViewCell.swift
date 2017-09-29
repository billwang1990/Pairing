//
//  PairTableViewCell.swift
//  Pairing
//
//  Created by Yaqing Wang on 29/09/2017.
//  Copyright © 2017 Yaqing Wang. All rights reserved.
//

import UIKit

class PairTableViewCell: UITableViewCell {
    @IBOutlet weak var leftGuy: UILabel!
    @IBOutlet weak var pikaqiu: UIImageView!
    @IBOutlet weak var rightGuy: UILabel!
    
    var pair: Pairing? {
        didSet {
            if let p = pair {
                leftGuy.text = p.firstPersonName
                rightGuy.text = p.secondPersonName
                pikaqiu.isHidden = p.secondPersonName != nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
