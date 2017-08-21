//
//  ViewController.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var playlistList = [Playlist]()
    let refreshControl = UIRefreshControl()
    
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var joinPlaylist: Playlist?
    
    @IBAction func joinButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Join", message: "enter an access Code to join another user's playlist", preferredStyle: .alert)
        
        alertController.addTextField {(textField: UITextField) in
            textField.placeholder = "-KqZYL0GC3NRYFP9Tq2Y"
        }
        
        alertController.addAction(UIAlertAction(title: "join", style: .default, handler: { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                
               let playlistRef = Database.database().reference().child("playlists").child(textField.text!)
                
                
                playlistRef.observeSingleEvent(of: DataEventType.value , with: { (snapshot) in
                    if Playlist(snapshot: snapshot) == nil {
                        return
                    } else {
                        self.joinPlaylist = Playlist(snapshot: snapshot)!
                        
                        self.performSegue(withIdentifier: "joinPlaylist", sender: self)
                    //prtformsegue
                    }
                })
                
            }
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(playlistList.count)
        return playlistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistCell
        let playlist = playlistList[indexPath.row]
        cell.accessCodeLabel.text = ("Access Code: \(playlist.accessCode)")
        cell.playlistNameLabel.text = playlist.playlistName
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "displayPlaylist" {
                if let cell = sender as? UITableViewCell {
                    let index = tableView.indexPath(for: cell)
                    let playlist = playlistList[(index?.row)!]
                    let displayPlaylistViewController = segue.destination as! DisplayPlaylistViewController
                    displayPlaylistViewController.selectedPlaylist = playlist
                    displayPlaylistViewController.hidesBottomBarWhenPushed = true
                    
                    
                }
                print ("hello")
            } else if identifier == "joinPlaylist" {
                let joinPlaylistViewController = segue.destination as! JoinPlaylistViewController
                joinPlaylistViewController.playlist = joinPlaylist
                joinPlaylistViewController.hidesBottomBarWhenPushed = true
                
            }else if identifier == "newPlaylist" {
                //                PlaylistService.I.create(playlistName: "playlistName")
                
                let displayPlaylistViewController = segue.destination as! DisplayPlaylistViewController
                displayPlaylistViewController.hidesBottomBarWhenPushed = true
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // print((Auth.auth().currentUser?.uid)!)
        self.tableView.rowHeight = 66
        
        UserService.I.observeUser = { user in
            UserService.I.playlists(for: user.uid, completion: { (playlist) in
                self.playlistList = playlist
                print(playlist.count)
                self.tableView.reloadData()
            })
        }
        
        refreshControl.addTarget(self, action: #selector(reloadList), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let deletedPlaylist = playlistList[indexPath.row]
        
        let selectedPlaylist = deletedPlaylist.id
        let ref = Database.database().reference().child("playlists").child(selectedPlaylist!)
        let musicRef = Database.database().reference().child("music").child(selectedPlaylist!)
        
        ref.removeValue()
        musicRef.removeValue()
        self.tableView.reloadData()
    }
    
    
    func reloadList() {
        UserService.I.playlists(for: (Auth.auth().currentUser?.uid)!, completion: { (playlists) in
            self.playlistList = playlists
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.tableView.reloadData()
        })
    }
    
    
    
   
    
}


