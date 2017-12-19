//
//  User.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 07/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import GoogleSignIn
import os.log

class User: NSObject, NSCoding {

    // MARK: Properties
    var user: GIDGoogleUser
    var settings: Settings?

    // MARK: Initialization
    init(user: GIDGoogleUser,
         settings: Settings?=Settings(downloadQuality: "low", keepDownloadHistory: false)) {
        self.user = user
        self.settings = settings
    }

    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(user, forKey: "user")
        aCoder.encode(settings, forKey: "settings")
    }
    required convenience init?(coder aDecoder: NSCoder) {
        guard let user = aDecoder.decodeObject(forKey: "user") as? GIDGoogleUser else {
            os_log("Unable to decode the user", log: OSLog.default, type: .debug)
            return nil
        }
        guard let settings = aDecoder.decodeObject(forKey: "settings") as? Settings else {
            os_log("Unable to decode the settings object", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(user: user, settings: settings)
    }
}
