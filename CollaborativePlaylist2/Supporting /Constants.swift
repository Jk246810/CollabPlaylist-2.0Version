//
//  Constants.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import Foundation

struct Constants {
    //storing spotify information for the credentials 
    static let clientID = "27094f14e3b842d28bdffcc9d3f5d863"
    static let redirectURL = URL(string: "collaborativePlaylist2://")!
    static let sessionUserDefaultsKey = "spotifySession"
    
    
    struct Segue {
        static let toCreateUsername = "toCreateUsername"
    }
    
    struct UserDefaults {
        static let currentUser = "currentUser"
        static let uid = "uid"
        static let username = "username"
    }
}
