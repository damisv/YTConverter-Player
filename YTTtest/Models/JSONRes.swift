//
//  JSONRes.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 15/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit

struct JSONRes {

    // MARK: Properties
    let vidID: String
    let vidTitle: String
    let vidInfo: [String: TrackQuality]

    // MARK: Initialization
    init?(vidID: String, vidTitle: String, vidInfo: [String: TrackQuality]) {
        self.vidID = vidID
        self.vidTitle = vidTitle
        self.vidInfo = vidInfo
    }
}

struct TrackQuality {

    // MARK: Properties
    let bitRate: Int
    let mp3Size: String
    let dloadUrl: String

    // MARK: Initialization
    init?(bitRate: Int, mp3Size: String, dloadUrl: String) {
        self.bitRate = bitRate
        self.mp3Size = mp3Size
        self.dloadUrl = dloadUrl
    }
}
