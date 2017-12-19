//
//  Video.swift
//  YTTtest
//
//  Copyright © 2017 Damian. All rights reserved.
//
import UIKit
import os.log
import RxSwift

class Video {

    // MARK: Properties
    var identifier: String
    var title: String
    var thumbnail: UIImage?
    var uploader: String
    var downloader: Downloader?
    var downloadProgress = Variable<Double>(0.0)
    let disposeBag = DisposeBag()

    // MARK: Initialization
    init?(identifier: String, title: String, uploader: String, thumbnail: UIImage?=UIImage(named: "defaultPhoto")) {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }
        self.identifier = identifier
        self.title = title
        self.thumbnail = thumbnail
        self.uploader = uploader
        self.downloader = Downloader(video: self)
//        downloader?.downloadProgress.asObservable()
//            .subscribe(onNext: { [unowned self]value in
//                self.downloadProgress.value = value
//                print("\(self.title): \(value)")
//            })
//            .disposed(by:disposeBag)
    }

    // MARK: Public Methods
    func downloadConvertedVideo() {
        downloader?.getConvertedVideo()
    }
    func updateProgress(value: Double) {
        self.downloadProgress.value = value
    }
}
