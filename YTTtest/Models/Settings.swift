//
//  Settings.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 07/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import os.log

class Settings: NSObject, NSCoding {

    struct PropertyKey {
        static let downloadQuality = "downloadQuality"
        static let keepDownloadHistory = "keepDownloadHistory"
    }

    // MARK: Properties
    var downloadQuality: String
    var keepDownloadHistory: Bool

    // MARK: Initialization
    init(downloadQuality: String, keepDownloadHistory: Bool) {
        self.downloadQuality = downloadQuality
        self.keepDownloadHistory = keepDownloadHistory
    }

    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(downloadQuality, forKey: PropertyKey.downloadQuality)
        aCoder.encode(keepDownloadHistory, forKey: PropertyKey.keepDownloadHistory)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let downloadQuality = aDecoder.decodeObject(forKey: PropertyKey.downloadQuality) as? String else {
            os_log("Unable to decode the Settings", log: OSLog.default, type: .debug)
            return nil
        }
        guard let keepDownloadHistory = aDecoder.decodeObject(forKey: PropertyKey.keepDownloadHistory) as? Bool else {
            os_log("Unable to decode the Settings", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(downloadQuality: downloadQuality, keepDownloadHistory: keepDownloadHistory)
    }
}
