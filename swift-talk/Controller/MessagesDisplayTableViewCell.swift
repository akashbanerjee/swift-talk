//
//  MessagesDisplayTableViewCell.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/19/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit

class MessagesDisplayTableViewCell: UITableViewCell {

    @IBOutlet weak var dp: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var email: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
