//
//  Playlist.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 22/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import os.log

class Playlist: NSObject, NSCoding {

    // MARK: Properties
    struct PropertyKey {
        static let identifier = "identifier"
        static let title = "title"
        static let tracks = "tracks"
    }

    var identifier: String
    var title: String
    var tracks: [Track]?

    // MARK: Initialization
    init?(identifier: String, title: String, tracks: [Track]?) {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }
        self.identifier = identifier
        self.title = title
        self.tracks = tracks
    }

    // MARK: Public Methods
    func savePlaylist() {
        var tempPlaylistArray = TrackLibrary.sharedInstance.playlists.value
        tempPlaylistArray.append(self)
        if AppFileManager.save(data: tempPlaylistArray, toFile: AppFileManager.PlaylistArchiveURL) {
            TrackLibrary.sharedInstance.loadPlaylists()
        }
        //Toast
    }
    func deletePlaylist(onSuccess completion: @escaping () -> Void, onFail fail: @escaping () -> Void) {
        var tempPlaylistArray = TrackLibrary.sharedInstance.playlists.value
        for (index, playlist) in tempPlaylistArray.enumerated() {
            if playlist.identifier.elementsEqual(identifier) {
                tempPlaylistArray.remove(at: index)
                (TrackLibrary.sharedInstance.removePlaylistFromCurrentLibrary(playlistToRemove: playlist)
                && AppFileManager.save(data: tempPlaylistArray,
                                       toFile: AppFileManager.PlaylistArchiveURL)) ? completion():fail()
            }
        }
    }
    func checkIfTrackExistsOnThis(trackGiven: Track) -> Bool {
        for track in tracks! {
            if trackGiven.identifier.elementsEqual(track.identifier) {
                return true
            }
        }
        return false
    }

    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: PropertyKey.identifier)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(tracks, forKey: PropertyKey.tracks)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: PropertyKey.identifier) as? String else {
            os_log("Unable to decode the playlist id", log: OSLog.default, type: .debug)
            return nil
        }
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the playlist title", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tracks = aDecoder.decodeObject(forKey: PropertyKey.tracks) as? [Track] else {
            os_log("Unable to decode the playlist songs", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(identifier: identifier, title: title, tracks: tracks)
    }
}
