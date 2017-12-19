//
//  MusicPlayer.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 21/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import os.log
import RxSwift

enum RemoteControlEvent {
    case playing, pause, stop
}

class MyMusicPlayer: NSObject, AVAudioPlayerDelegate {
    // MARK: Properties
    static let sharedInstance = MyMusicPlayer()
    static let audioSession = AVAudioSession.sharedInstance()

    let trackLibrary = TrackLibrary.sharedInstance
    let disposeBag = DisposeBag()

    var player: AVAudioPlayer = AVAudioPlayer()
    var currentTrackIndex = 0
    var initiated: Bool = false

    var playlistID: String = "playlistID"
    var tracks: [Track] = [Track]()

    let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

    // RX
    var currentTrack = Variable(Track())
    var lastRemoteControlEvent = Variable(RemoteControlEvent.pause)

    // MARK: Initialization

    override init() {
        super.init()
        setupLibrary()
        lastRemoteControlEvent.value = .stop
    }
    func setupLibrary() {
        trackLibrary.tracks.asObservable()
            .subscribe(onNext: { [unowned self] array in
                self.tracks = array
                if !self.initiated {
                    self.queueTrack {
                        self.initiated = true
                    }
                }
            })
            .disposed(by: disposeBag)
        trackLibrary.playlistTracks.asObservable()
            .subscribe(onNext: { [unowned self] array in
                self.tracks = array
                self.currentTrackIndex = 0
            })
            .disposed(by: disposeBag)
        trackLibrary.loadTracks {}
        trackLibrary.loadPlaylists()
    }
    // MARK: Public Methods
    func play() {
        if !player.isPlaying {
            player.play()
            lastRemoteControlEvent.value = .playing
        }
    }
    func stop() {
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
            lastRemoteControlEvent.value = .stop
        }
    }
    func pause() {
        if player.isPlaying {
            player.pause()
           lastRemoteControlEvent.value = .pause
        }
    }
    func togglePlayPause() {
        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }
    func playSong(identifier: String) {
        stop()
        if playTrackById(identifier: identifier) {
            queueTrack {
                self.playSetup()
                self.play()
            }
        } else {
            trackLibrary.loadTracks {
                self.playSong(identifier: identifier)
            }
        }
    }
    func playPlaylist(identifier: String) {
        trackLibrary.loadPlaylistTracks(playlistID: identifier) {
            self.stop()
            self.playlistID = identifier
            self.queueTrack {
                self.playSetup()
                self.play()
            }
        }
    }
    func playSetup() {
        currentTrack.value = getCurrentTrackInfo()
        updateInfoCenter()
    }
    func nextTrack(trackFinishedPlaying: Bool) {
        var playerWasPlaying = true
        if player.isPlaying {
            stop()
            playerWasPlaying = false
        }
        currentTrackIndex += 1
        if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }
        queueTrack {
            self.playSetup()
            if playerWasPlaying {
                self.play()
            }
        }
    }
    func nextTrack() {
        var playerWasPlaying = false
        if player.isPlaying {
            stop()
            playerWasPlaying = true
        }
        currentTrackIndex += 1
        if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }
        queueTrack {
            self.playSetup()
            if playerWasPlaying {
                self.play()
            }
        }
    }
    func previousSong() {
        var playerWasPlaying = false
        if player.isPlaying {
           stop()
            playerWasPlaying = true
        }
        currentTrackIndex -= 1
        if currentTrackIndex < 0 {
            currentTrackIndex = tracks.count - 1
        }
        queueTrack {
            self.playSetup()
            if playerWasPlaying {
                self.play()
            }
        }
    }
    func getCurrentTrackInfo() -> Track {
        return tracks[currentTrackIndex]
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nextTrack(trackFinishedPlaying: true)
        }
    }

    // MARK: Private Methods
    private func queueTrack(onSuccess completion: @escaping () -> Void) {
        if tracks.count>0 {
            let temp = self.path+"/"+tracks[currentTrackIndex].identifier+".mp3"
            let url = URL(string: temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            do {
                player = try AVAudioPlayer(contentsOf: url!)
            } catch {
                os_log("Error queue track", log: OSLog.default, type: .error)
                return
            }
            player.delegate = self
            player.prepareToPlay()
            backgroundPlayerAvailable()
            completion()
        }
    }
    private func playTrackById(identifier: String) -> Bool {
        for (index, track) in tracks.enumerated() {
            if track.identifier.elementsEqual(identifier) {
                currentTrackIndex = index
                return true
            }
        }
        return false
    }
    private func backgroundPlayerAvailable() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [])
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    private func updateInfoCenter() {
        let tempArtwork = MPMediaItemArtwork(boundsSize: (tracks[currentTrackIndex].thumbnail?.size)!,
                                             requestHandler: {_ in
            return self.tracks[self.currentTrackIndex].thumbnail!
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: tracks[currentTrackIndex].title,
            MPMediaItemPropertyArtist: tracks[currentTrackIndex].uploader,
            MPMediaItemPropertyArtwork: tempArtwork,
            MPMediaItemPropertyPlaybackDuration: player.duration as Any,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
    }
}
