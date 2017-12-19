//
//  TrackLibrary.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 08/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import RxSwift

class TrackLibrary {

    static let sharedInstance = TrackLibrary()

    // MARK: Properties
    var tracks = Variable<[Track]>([Track]())
    var playlists = Variable<[Playlist]>([Playlist]())
    var playlistTracks = Variable<[Track]>([Track]())
    var library = [Track]()

    // MARK: Initialization
    init() {
        self.library = loadTrackArchive()
    }

    // MARK: Public Methods
    func loadTracks(onSuccess completion: @escaping () -> Void) {
        tracks.value = loadTrackArchive()
        completion()
    }
    func loadPlaylists() {
        playlists.value = loadPlaylistArchive()
    }
    func loadPlaylistTracks(playlistID: String, onSuccess completion: @escaping () -> Void) {
        playlistTracks.value = loadPlaylistTracks(playlistID: playlistID)
        completion()
    }
    func removeTrackFromCurrentLibrary(trackToRemove: Track) -> Bool {
        for (index, track) in library.enumerated() {
            if track.identifier.elementsEqual(trackToRemove.identifier) {
                library.remove(at: index)
                return AppFileManager.save(data: library, toFile: AppFileManager.TrackArchiveURL)
            }
        }
        return false
    }
    func removePlaylistFromCurrentLibrary(playlistToRemove: Playlist) -> Bool {
        for (index, playlist) in playlists.value.enumerated() {
            if playlist.identifier.elementsEqual(playlistToRemove.identifier) {
                playlists.value.remove(at: index)
                return AppFileManager.save(data: playlists.value, toFile: AppFileManager.PlaylistArchiveURL)
            }
        }
        return false
    }

    // MARK: Private methods
    private func loadTrackArchive() -> [Track] {
        return AppFileManager.load(fromFile: AppFileManager.TrackArchiveURL)! as [Track]
    }
    private func loadPlaylistArchive() -> [Playlist] {
        return AppFileManager.load(fromFile: AppFileManager.PlaylistArchiveURL)! as [Playlist]
    }
    private func loadPlaylistTracks(playlistID: String) -> [Track] {
        for playlist in playlists.value {
            if playlist.identifier.elementsEqual(playlistID) {return playlist.tracks!}
        }
        return [Track]()
    }
}
