//
//  User.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

struct User {
    let uid: String
    let username: String
}

extension User {
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
    }
    
   
    
    func toDicitionary() -> [String : Any] {
        var dict = [String:Any]()
        
        dict["uid"] = uid
        dict["username"] = username
        
        return dict
    }
}



