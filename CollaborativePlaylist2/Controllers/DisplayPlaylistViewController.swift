//
//  DisplayPlaylistViewController.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/13/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseDatabase
import FirebaseStorage
import Spartan
import Kingfisher
import FirebaseDatabaseUI
import AVFoundation



class DisplayPlaylistViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    
   
    var auth = SPTAuth.defaultInstance()!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    
    let queue = DispatchQueue(label: "serial")
    var playAllSongs = [String]()
    
    var listMusic: [Music?] {
        var list = [Music]()
        self.dataSource?.items.forEach {
            if let song = Music(snapshot: $0) {
                list.append(song)
            }
        }
        return list
    }
    
    var selectedPlaylist: Playlist?
    
    var didStartPlayingMusic = false

    
    var isPaused = true
    var currentPoseIndex = 0.00
    var timer = Timer()
    var count = 0
    var trackDuration = 0
    var fullTrackDuration = 0
    var indexProgressBar = 0.00
    
    var playIndex: Int = 0 // index of current playing track
    var furthestIndex : Int = 0
    
    //animator 
    
    //Activity indicator
           
    fileprivate var dataSource: FUITableViewDataSource? // step 1
    fileprivate var songsQuery: DatabaseQuery? // step2 + querty in FirebaseQueryService (same as getSongs)
    
    var isNewPlaylist: Bool{
        return self.selectedPlaylist == nil
    }
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistNameTextField: UITextField!
    
    @IBOutlet weak var playAllSongsButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var currentSongImageView: UIImageView!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    
    
    @IBAction func nextTapped(_ sender: UIButton) {
        playAllSongsButton.isSelected = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DisplayPlaylistViewController.updateTimer), userInfo: nil, repeats: true)
        
        
        
        if !listMusic.isEmpty {
            if playIndex == listMusic.count - 1 {
                player?.skipNext(printError(_:))
//                if let playbackState = self.player?.playbackState, didStartPlayingMusic {
//                    print("here")
//                    let resume = !playbackState.isPlaying
//                    self.player?.setIsPlaying(resume, callback: printError(_:))
////                    timer.invalidate()
//                    playAllSongsButton.isSelected = false
//                }
           
                
            }else {
                nextButton.isEnabled = true
                nextButton.isHidden = false
                incrementPlayIndex()
                guard let track = listMusic[playIndex] else {return}
                
                self.trackDuration = track.length / 1000
                self.fullTrackDuration = track.length / 1000
                indexProgressBar = 0
                player?.playSpotifyURI(listMusic[playIndex]?.uri, startingWith: 0, startingWithPosition: 0, callback: printError(_:))
                loadSongDisplay()
                 

            }
        }
    }
    
    
    @IBAction func previousTapped(_ sender: Any) {
        playAllSongsButton.isSelected = true
        timer.invalidate()
        runTimer()
        
        if !listMusic.isEmpty {
            if playIndex == 0 {
                player?.skipPrevious(printError(_:))
                
            } else {
                decrementPlayIndex()
                guard let track = listMusic[playIndex] else {return}
                self.trackDuration = (track.length) / 1000
                indexProgressBar = 0
                self.fullTrackDuration = (track.length) / 1000
                player?.playSpotifyURI(listMusic[playIndex]?.uri, startingWith: 0, startingWithPosition: 0, callback: printError(_:))
            }
            loadSongDisplay()
        }
        
    }
    
    
    
    
//Mark: - Button Actions
   
    @IBAction func playAllSongsButtonTapped(_ sender: UIButton) {
        playAllSongsButton.isSelected = !playAllSongsButton.isSelected
        
        if playAllSongsButton.isSelected {
            
            isPaused = false
            runTimer()
            
        }else{
            isPaused = true
            
            timer.invalidate()
            
           
        }
        
            if !listMusic.isEmpty {
            //            player?.playSpotifyURI(listMusic[playIndex]?.uri, startingWith: 0, startingWithPosition: 0, callback: printError(_:))
                if let playbackState = self.player?.playbackState, didStartPlayingMusic {
                    print("here")
                    let resume = !playbackState.isPlaying
                    self.player?.setIsPlaying(resume, callback: printError(_:))
                
                }else {
                    didStartPlayingMusic = true
                    self.player?.playSpotifyURI(listMusic[playIndex]?.uri, startingWith: 0, startingWithPosition: 0, callback: printError(_:))
                    print("yay its playing")
                }
            
                loadSongDisplay()
            
            } else{
                print("no tracks to play")
            }
        
        
    }
    

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if isNewPlaylist {
            PlaylistService.I.create(playlistName: playlistNameTextField.text ?? "")
        } else {
             self.selectedPlaylist?.playlistName = playlistNameTextField.text ?? self.selectedPlaylist!.playlistName
            
            
            PlaylistService.I.update(playlist: self.selectedPlaylist!)
        }
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    @IBOutlet weak var LoginToSpotify: UIButton!
    
    @IBAction func LoginToSpotifyButtonTapped(_ sender: UIButton) {
        if UIApplication.shared.openURL(auth.spotifyWebAuthenticationURL()) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
        
    }
    
    
    
    
    
//MARK: - Audio
    
    
  
  
    
}

//Mark: Testing the Pause and Play 
extension DisplayPlaylistViewController {
    func runTimer () {
        getNextPoseData()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(DisplayPlaylistViewController.updateTimer)), userInfo: nil, repeats: true)
        
    }
    
    func printError(_ error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func updateTimer () {
        let songs = listMusic
        if songs.isEmpty {
            return
        }
      
        if trackDuration <= 0 {
            guard let track = listMusic[playIndex] else {return}
            self.trackDuration = (track.length) / 1000
            self.fullTrackDuration = (track.length) / 1000
        } else {
            trackDuration = trackDuration - 1
            if indexProgressBar != 0 && indexProgressBar == Double(fullTrackDuration) {
                getNextPoseData()
                indexProgressBar = 0
                if !listMusic.isEmpty {
                    if playIndex == listMusic.count - 1 {
                       player?.skipNext(printError(_:))
                    } else {
                        currentPoseIndex = 0
                        incrementPlayIndex()
                        guard let track = listMusic[playIndex] else {return}
                       
                        self.trackDuration = track.length / 1000
                        self.fullTrackDuration = track.length / 1000
                        
                        
                        player?.playSpotifyURI(listMusic[playIndex]?.uri, startingWith: 0, startingWithPosition: 0, callback: printError(_:))
                        tableView.reloadData()
                        loadSongDisplay()
//
                    }
                }
            }
            
            progressBar.progress = Float(indexProgressBar)/Float(fullTrackDuration-1)
            indexProgressBar += 1
        }
        
        let (_,m, s) = secondsToHoursMinutesSeconds (seconds: trackDuration)
        let (_,min, sec) = secondsToHoursMinutesSeconds (seconds: Int(indexProgressBar))
        if s < 10  {
            timerLabel.text = "0\(m):0\(s)" // updates the label            startTimer.text = "0\(min):0\(sec)"
        } else {
            timerLabel.text = "0\(m):\(s)"
            startLabel.text = "0\(min):\(sec)"
        }
        if sec < 10  {
            startLabel.text = "0\(min):0\(sec)"
        } else {
            startLabel.text = "0\(min):\(sec)"
        }
    
    
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printSecondsToHoursMinutesSeconds (seconds:Int) -> () {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds: trackDuration)
        print ("\(h) Hours, \(m) Minutes, \(s) Seconds")
    }
    
    func getNextPoseData() {
        currentPoseIndex += 1
        print("bye \(currentPoseIndex)")
        
    }
    
    func incrementPlayIndex() {
        if furthestIndex == playIndex {
            furthestIndex += 1
        }
        playIndex += 1
    }
    func decrementPlayIndex() {
        playIndex -= 1
        
    }
    
    func setProgressBar() {
        if indexProgressBar == Double(trackDuration) {
            getNextPoseData()
            // reset the progress counter
            indexProgressBar = 0
        }
        indexProgressBar += 1
    
    
    }
}


//MARK: - Life cycle
extension DisplayPlaylistViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playAllSongsButton.isEnabled = false
        self.nextButton.isEnabled = false
        self.previousButton.isEnabled = false
        
        tableView.rowHeight = 66
       
        
        
        setupDataSource()
        
         NotificationCenter.default.addObserver(self, selector: #selector(DisplayPlaylistViewController.authSessionUpdated), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        
      
        
        setProgressBar()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        if let playlist = selectedPlaylist {
            playlistNameTextField.text = playlist.playlistName
        }
        if (auth.session != nil) {
            if (auth.session.isValid()) {
                self.LoginToSpotify.isHidden = true
                playAllSongsButton.isEnabled = true
                nextButton.isEnabled = true
                previousButton.isEnabled = true
                authSessionUpdated()
                
            } else {
                self.LoginToSpotify.isHidden = false
                playAllSongsButton.isEnabled = true
                nextButton.isEnabled = true
                previousButton.isEnabled = true
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player?.setIsPlaying(false, callback: { (error: Error?) in
            do {
                try self.player?.stop()
            } catch {
                print("error")
            }
        
        })
    
    }
}

//MARK: - Data source
extension DisplayPlaylistViewController {
    func setupDataSource() {
        if !isNewPlaylist {
            self.songsQuery = FirebaseQueryService.I.getSongs(for: self.selectedPlaylist!)
            self.setupTableView()
        }
    }
    
    private func setupTableView() { // step 3
        self.dataSource = tableView.bind(to: songsQuery!, populateCell: { tableView, indexPath, snapshot in
            let cell = tableView.dequeueReusableCell(withIdentifier: "addedSongCell") as! addedSongCell
            
            if let song = Music(snapshot: snapshot) {
        
                
                cell.configure(with: song)
                
               
            
                
            
            
            }
            
            return cell
        })
        
        
    }

    
}



//Mark: - Current Song Image Display
extension DisplayPlaylistViewController {
    func loadSongDisplay() {
        if !listMusic.isEmpty {
            let song = listMusic[playIndex]
            let imageURL = URL(string: (song?.mainImage)!)
            currentSongImageView.kf.setImage(with: imageURL)
        }
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.currentSongImageView.alpha = 0.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.currentSongImageView.alpha = 1.0
        }, completion: nil)
        
    }
}



//MARK: - Segue
extension DisplayPlaylistViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "songsList" {
                let listSpotifyMusicViewController = segue.destination as! ListSpotifyMusicViewController
                
                if isNewPlaylist {
                    PlaylistService.I.create(playlistName: playlistNameTextField.text ?? "") { playlist in
                        listSpotifyMusicViewController.playlist = playlist
                        listSpotifyMusicViewController.playlist?.playlistName = self.playlistNameTextField.text ?? ""
                        self.setupDataSource()
                    }
                    
                    return
                }
                
                selectedPlaylist?.playlistName = playlistNameTextField.text ?? ""
                listSpotifyMusicViewController.playlist = selectedPlaylist
            }
        }
    }
}


//MARK: - LOGIN TO SPOTIFY
extension DisplayPlaylistViewController {
    
    func authSessionUpdated() {
       let auth = SPTAuth.defaultInstance()
       
        if (auth?.session.isValid())! {
            self.LoginToSpotify.isHidden = true
            initializePlayer(authSession: auth!.session)
        }
    }
    
    
    
    func initializePlayer(authSession:SPTSession){
        if (self.player != nil) {
            return
        }
        
        self.player = SPTAudioStreamingController.sharedInstance()
        
        do {
            try self.player?.start(withClientId: auth.clientID)
            
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            self.player!.login(withAccessToken: authSession.accessToken)
        } catch (let error as NSError) {
            print(error.localizedDescription)
            return
        }
        
        
        
        
        Spartan.authorizationToken = authSession.accessToken
        print("hello")
        Spartan.loggingEnabled = true
        
    }
    
}

extension DisplayPlaylistViewController {
    func audioStreaming(_audioStreaming: SPTAudioStreamingController!, didChangePlaybackState isPlaying: Bool) {
        print("is playing =", isPlaying);
        if (isPlaying) {
            activateAudioSession()
        } else {
            deactivateAudioSession()
        }
    }
    
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
        } catch {}
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            
        } catch {}
    }
}


