//
//  PlaylistCell.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/13/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {

    @IBOutlet weak var playlistNameLabel: UILabel!
    
    
    @IBOutlet weak var accessCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
