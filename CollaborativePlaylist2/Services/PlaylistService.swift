//
//  PlaylistService.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/17/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import Foundation
import UIKit
import Firebase


struct PlaylistService {
    static let I = PlaylistService()
    let currentUser = UserService.I.currentUser
    let db = Database.database().reference()
    
    
    func create(playlistName: String, completion: ((Playlist) -> Void)? = nil) {
        let ref = db.child("playlists").childByAutoId()
        if let user = UserService.I.currentUser {
            let playlist = Playlist(id: ref.key, playlistName: playlistName, accessCode: ref.key, host: user, songs: [])
            
            
            var childUpdates = [String : Any]()
            childUpdates["playlists/\(ref.key)"] = playlist.toDictionary()
            
            db.updateChildValues(childUpdates) { _, _ in
                let playlist = Playlist(id: ref.key,
                                        playlistName: playlistName,
                                        accessCode: ref.key,
                                        host: user,
                                        songs: [])
                completion?(playlist)
            }
        }
    }
    
    func update(playlist: Playlist) {
        var childUpdates = [String : Any]()
        guard let id = playlist.id else { return }
        childUpdates["playlists/\(id)"] = playlist.toDictionary()
        db.updateChildValues(childUpdates)
    }
    
    
}
