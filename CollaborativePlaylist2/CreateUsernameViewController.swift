//
//  CreateUsernameViewController.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.I.create(firUser, username: username) { (user) in
            guard let user = user else {
                return
            }
            
//            UserService.I.setCurrent(user, writeToUserDefaults: true)
            
            print("create new user: \(user.username)")
            
            let initialViewController:UIViewController
            
            initialViewController = UIStoryboard.initialViewController(for: .main)
            self.show(initialViewController, sender: nil)
           
        }
    }

}
