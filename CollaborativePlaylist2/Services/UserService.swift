//
//  UserService.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

class UserService {
    static let I = UserService()
    
    private let db = Database.database().reference()
    
    var observeUser: ((User) -> Void)?
    
    var currentUser: User! {
        didSet {
            if currentUser != nil {
                observeUser?(currentUser)
            }
        }
    }
    
    
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.loadUserData(user: user)
        }
    }
    
    func loadUserData(user: FIRUser?) {
        guard let uid = user?.uid else { return }
        db.child("users/\(uid)").observe(.value, with: { snapshot in
            self.currentUser = User(snapshot: snapshot)
        })
    }
    
    
    func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        self.currentUser = user
    }
    
    func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    
    
    
     func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    func playlists(for user: String, completion: @escaping ([Playlist]) -> Void) {
        let ref = Database.database().reference().child("playlists")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            
            let playlists: [Playlist] = snapshot
                
                .reversed()
                
                .flatMap (
                    Playlist.init
            )
                .filter {
                    return $0.host.uid == self.currentUser.uid
            }
            print(playlists.count)
            completion(playlists)
            
        })
    }
    
    
    
}
