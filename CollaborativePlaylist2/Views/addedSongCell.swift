//
//  addedSongCell.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/13/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import Kingfisher


class addedSongCell: UITableViewCell {
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    

   
    func configure(with song: Music) {
        
        songNameLabel.text = song.name
//        artistNameLabel.text = 
        let imageURL = URL(string: song.mainImage)
        songImageView.kf.setImage(with: imageURL)
    }
    
  
}
