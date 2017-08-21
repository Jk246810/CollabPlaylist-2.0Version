//
//  Playlist.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/17/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import Firebase

struct Playlist {
    var id: String? = nil
    var playlistName: String
    let accessCode: String
    let host: User
    var songs = [String]()
}

extension Playlist {
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let playlistName = dict["playlistName"] as? String,
            let userDict = dict["host"] as? [String: Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
            else {
                return nil
        }
        
        self.id = snapshot.key
        self.accessCode = snapshot.key
        self.playlistName = playlistName
        self.host = User(uid: uid, username: username)
        
        if let songs = dict["songs"] as? [String] {
            self.songs = songs
        }
    }
    
    func toDictionary() -> [String: Any]{
        var dict = [String:Any]()
        
        dict["accessCode"] = accessCode
        dict["playlistName"] = playlistName
        dict["host"] = host.toDicitionary()
        if !songs.isEmpty {
            dict["songs"] = songs
        }

        
        return dict
    }
}
