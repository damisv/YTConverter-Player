//
//  Downloads.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 07/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import RxSwift

class Downloads {

    static let sharedInstance = Downloads()

    // MARK: Properties
    var downloadsArray: Variable<[Video]> = Variable([Video]())

    init() {}

    func addToDownloadsArray(video: Video) {
        downloadsArray.value.append(video)
    }
    func removeCompletedDownload(video: Video) {
        for (index, downloadingVideo) in downloadsArray.value.enumerated() {
            if video.identifier.elementsEqual(downloadingVideo.identifier) { downloadsArray.value.remove(at: index)}
        }
    }
    func isNowDownloading(videoID: String) -> Bool {
        for video in downloadsArray.value {
            if video.identifier.elementsEqual(videoID) { return true}
        }
        return false
    }
}
