//
//  Downloader.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 15/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import os.log
import SwiftyJSON
import RxSwift

class Downloader: NSObject, URLSessionDownloadDelegate {

    private static let baseUrl = "http://youtubetoany.com/@api/json/mp3/"

    // MARK: Properties
    var url: URL!
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var video: Video
    var videoQ = [String: TrackQuality]()
    var library = [Track]()

    // MARK: Initialization
    init(video: Video) {
        self.video = video
    }

    // MARK: Implemented Methods
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(video.identifier+".mp3")
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
        let trackToBeSaved = Track(identifier: video.identifier,
                                   title: video.title,
                                   uploader: video.uploader,
                                   thumbnail: video.thumbnail,
                                   localUrl: destinationUrl.absoluteString)
        if (trackToBeSaved?.saveTrack())! {
            Downloads.sharedInstance.removeCompletedDownload(video: video)
            TrackLibrary.sharedInstance.loadTracks(onSuccess: {
                print("Library Updated!")
            })
            // Toast
        }
    }
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                             didWriteData bytesWritten: Int64,
                             totalBytesWritten: Int64,
                             totalBytesExpectedToWrite: Int64) {
        video.updateProgress(value: Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Toast
        if error != nil {
            print("Download completed with error: \(error!.localizedDescription)")
        }
    }

    // MARK: Private Methods
    private func download(url: URL) {
        self.url = url
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: url.absoluteString)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self,
                                            delegateQueue: OperationQueue.main)
        let task = session.downloadTask(with: url)
        Downloads.sharedInstance.addToDownloadsArray(video: video)
        task.resume()
    }
    private func checkIfAlreadyDownloaded() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("\(video.identifier).mp3").path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    private func checkIfDownloading() -> Bool {
        return Downloads.sharedInstance.isNowDownloading(videoID: video.identifier)
    }

    // MARK: Public Methods
    func getConvertedVideo() {
        if !checkIfAlreadyDownloaded() && !checkIfDownloading() {
            let link = URL(string: Downloader.baseUrl+video.identifier)!
            let session = URLSession.shared
            let request = URLRequest(url: link)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, _, error ) in
                guard error == nil else { return }
                guard let data = data else { return }
                if let res = String(data: data, encoding: String.Encoding.utf8) {
                    if let tempString = res.range(of: "<script") {
                        let tempRes = String(res[..<tempString.lowerBound])
                        if let jsonFromString = tempRes.data(using: .utf8, allowLossyConversion: false) {
                            do {
                                let json = try JSON(data: jsonFromString)
                                for i in 0...4 {
                                    let temp = json["vidInfo"][String(i)]
                                    switch temp["bitrate"] {
                                    case 320:
                                        self.videoQ["highest"] = TrackQuality(bitRate: Int(temp["bitrate"].stringValue)!,
                                                                              mp3Size: temp["mp3size"].stringValue,
                                                                              dloadUrl: String(temp["dloadUrl"].stringValue.dropFirst(2)))
                                    case 256:
                                        self.videoQ["high"] = TrackQuality(bitRate: Int(temp["bitrate"].stringValue)!,
                                                                           mp3Size: temp["mp3size"].stringValue,
                                                                           dloadUrl: String(temp["dloadUrl"].stringValue.dropFirst(2)))
                                    case 192:
                                        self.videoQ["medium"] = TrackQuality(bitRate: Int(temp["bitrate"].stringValue)!,
                                                                             mp3Size: temp["mp3size"].stringValue,
                                                                             dloadUrl: String(temp["dloadUrl"].stringValue.dropFirst(2)))
                                    case 128:
                                        self.videoQ["low"] = TrackQuality(bitRate: Int(temp["bitrate"].stringValue)!,
                                                                          mp3Size: temp["mp3size"].stringValue,
                                                                          dloadUrl: String(temp["dloadUrl"].stringValue.dropFirst(2)))
                                    case 64:
                                        self.videoQ["lowest"] = TrackQuality(bitRate: Int(temp["bitrate"].stringValue)!,
                                                                             mp3Size: temp["mp3size"].stringValue,
                                                                             dloadUrl: String(temp["dloadUrl"].stringValue.dropFirst(2)))
                                    default:
                                        return
                                    }
                                }
                                let videoToDownload = JSONRes(vidID: json["vidID"].stringValue,
                                                              vidTitle: json["vidTitle"].stringValue,
                                                              vidInfo: self.videoQ)
                                let downloadUrl = URL(string: ("http://"+(videoToDownload?.vidInfo["low"]?.dloadUrl)!))!
                                self.download(url: downloadUrl)
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            })
            task.resume()
        }
    }
}
