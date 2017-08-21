//
//  Music.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/26/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import Foundation
import Firebase

struct Music {

    let mainImage : String!
    let name: String!
    let uri: String!
    let length: Int
    let dateAdded: TimeInterval
    let user: User
    
    
    
}

extension Music {
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            
            let uri = dict["uri"] as? String,
            let name = dict["name"] as? String,
            let mainImage = dict["mainImage"] as? String,
            let length = dict["length"] as? Int,
            let dateAdded = dict["dateAdded"] as? Double,
            let userDict = dict["user"] as? [String: Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
        

            else{ return nil }

          self.uri = uri
          self.name = name
          self.mainImage = mainImage
          self.length = length
          self.dateAdded = dateAdded
          self.user = User(uid: uid, username: username)
        

    
    }

    func toDicitionary() -> [String : Any] {
        var dict = [String:Any]()
    

          dict["uri"] = uri
          dict["name"] = name
          dict["mainImage"] = mainImage
          dict["length"] = length
          dict["dateAdded"] = dateAdded
          dict["user"] = user.toDicitionary()
        
    
        return dict
    }
}
