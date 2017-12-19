//
//  FileManager.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 08/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import os.log

final class AppFileManager {

    static let fileManager = FileManager.default
    static let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let TrackArchiveURL = DocumentsDirectory.appendingPathComponent("tracks")
    static let PlaylistArchiveURL = DocumentsDirectory.appendingPathComponent("playlists")
    static let UserArchiveURL = DocumentsDirectory.appendingPathComponent("user")

    static func save<T>(data: T, toFile: URL) -> Bool {
        return NSKeyedArchiver.archiveRootObject(data, toFile: toFile.path)
    }
    static func load<T>(fromFile: URL) -> [T]? {
        let temp = NSKeyedUnarchiver.unarchiveObject(withFile: fromFile.path)
        if temp != nil {
            return temp as? [T]
        } else {
            return [T]()
        }
    }
    static func delete(name: String, format: String) -> Bool {
        do {
            try fileManager.removeItem(atPath: "\(path)/\(name).\(format)")
            return true
        } catch {
            // Toast
            return false
        }
    }

}
