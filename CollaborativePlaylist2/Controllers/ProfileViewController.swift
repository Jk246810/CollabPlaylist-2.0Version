//
//  ProfileViewController.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 8/9/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth.FIRUser

class ProfileViewController: UIViewController {
    
    let player = SPTAudioStreamingController.sharedInstance()

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
//            if player != nil && (player?.loggedIn)! {
//                player?.logout()
//            }
            try firebaseAuth.signOut()
            
            let initialViewController: UIViewController
            
            initialViewController = UIStoryboard.initialViewController(for: .login)
            
            self.show(initialViewController, sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = UserService.I.currentUser
        
        let ref = Database.database().reference().child("users").child((currentUser?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {
                return
            }
            self.usernameLabel.text = ("Username: \(dict["username"] as! String)")
            
        })
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "acknowledgments" {
                let acknowledgmentsViewController = segue.destination as! AcknowledgmentsViewController
                acknowledgmentsViewController.hidesBottomBarWhenPushed = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
