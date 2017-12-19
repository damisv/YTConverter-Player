//
//  Video.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 14/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//
import UIKit
import MediaPlayer
import os.log

class Track: NSObject, NSCoding {

    // MARK: Properties
    struct PropertyKey {
        static let identifier = "identifier"
        static let title = "title"
        static let localUrl = "localUrl"
        static let uploader = "uploader"
        static let thumbnail = "thumbnail"
    }

    var identifier: String
    var title: String
    var thumbnail: UIImage?
    var uploader: String
    var localUrl: String?
    var size: String?
    var duration: String?

    // MARK: Initialization
    override init() {
        self.identifier = ""
        self.title = ""
        self.uploader = ""
    }
    init?(identifier: String, title: String, uploader: String,
          thumbnail: UIImage?=UIImage(named: "defaultPhoto"), localUrl: String?="") {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }
        self.identifier = identifier
        self.title = title
        self.thumbnail = thumbnail
        self.uploader = uploader
        self.localUrl = localUrl
    }

    // MARK: Public Methods
    func saveTrack() -> Bool {
        var tempTrackArray = TrackLibrary.sharedInstance.library
        tempTrackArray.append(self)
        return AppFileManager.save(data: tempTrackArray, toFile: AppFileManager.TrackArchiveURL)
    }
    func addToPlaylist(playlistID: String) {
        let tempPlaylistTracks = TrackLibrary.sharedInstance.playlists.value
        for playlist in tempPlaylistTracks {
            if playlist.identifier.elementsEqual(playlistID) {
                if playlist.checkIfTrackExistsOnThis(trackGiven: self) {
                    return
                }
                playlist.tracks?.append(self)
                if AppFileManager.save(data: tempPlaylistTracks, toFile: AppFileManager.PlaylistArchiveURL) {
                    TrackLibrary.sharedInstance.loadPlaylists()
                }
            }
        }
    }
    func deleteTrack(onSuccess success: @escaping () -> Void, onFail fail: @escaping () -> Void) {
        // it should be done simpler !
        let tempPlaylistTracks = TrackLibrary.sharedInstance.playlists.value
        for playlist in tempPlaylistTracks {
            for (index, track) in (playlist.tracks?.enumerated())! {
                if track.identifier.elementsEqual(identifier) {
                    playlist.tracks?.remove(at: index)
                }
            }
        }
        (TrackLibrary.sharedInstance.removeTrackFromCurrentLibrary(trackToRemove: self)
            && AppFileManager.save(data: tempPlaylistTracks, toFile: AppFileManager.PlaylistArchiveURL)
            && AppFileManager.delete(name: identifier, format: "mp3")) ? success() : fail()
    }
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: PropertyKey.identifier)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(uploader, forKey: PropertyKey.uploader)
        aCoder.encode(localUrl, forKey: PropertyKey.localUrl)
        aCoder.encode(thumbnail, forKey: PropertyKey.thumbnail)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        // id and title are required.The initializer fails if not provided
        guard let identifier = aDecoder.decodeObject(forKey: PropertyKey.identifier) as? String else {
            os_log("Unable to decode the track id", log: OSLog.default, type: .debug)
            return nil
        }
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the track title", log: OSLog.default, type: .debug)
            return nil
        }
        guard let localUrl = aDecoder.decodeObject(forKey: PropertyKey.localUrl) as? String else {
            os_log("Unable to decode the track localUrl", log: OSLog.default, type: .debug)
            return nil
        }
        let thumbnail = aDecoder.decodeObject(forKey: PropertyKey.thumbnail) as? UIImage
        guard let uploader = aDecoder.decodeObject(forKey: PropertyKey.uploader) as? String else {
            os_log("Unable to decode the track uploader", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(identifier: identifier, title: title, uploader: uploader, thumbnail: thumbnail, localUrl: localUrl)
    }
}
