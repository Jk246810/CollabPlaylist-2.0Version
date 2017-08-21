//
//  SpotifySongsCell.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/31/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit

class SpotifySongsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
