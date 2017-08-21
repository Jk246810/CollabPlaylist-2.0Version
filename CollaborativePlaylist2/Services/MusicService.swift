//
//  MusicService.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/27/17.
//  Copyright © 2017 jameeeeeeeeeeeeeeeeeee. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct MusicService {
    static let I = MusicService()
    let db = Database.database().reference()
    
    func createSong(using post: Post, playlist: Playlist, trackId: String) {
        guard let currentUser = UserService.I.currentUser else {
            assertionFailure("Current user doesn't exist.")
            return
        }
        
        guard let playlistId = playlist.id else { return }
        
        let music = Music(mainImage: post.mainImageURL,
                          name: post.name,
                          uri: post.uri,
                          length: post.songDuration,
                          dateAdded: Date().timeIntervalSince1970,
                          user: currentUser)
        
        var childUpdates = [String: Any]()
        
        childUpdates["music/\(playlistId)/\(trackId)"] = music.toDicitionary()
        childUpdates["playlists/\(playlistId)/songs"] = playlist.songs
        
        db.updateChildValues(childUpdates)
    }
    
    
    
}
