//
//  YoutubeActions.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 07/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import RxSwift
import GoogleAPIClientForREST

class YouTubeActions: NSObject {

    // MARK: Properties
    static let sharedInstance = YouTubeActions()

    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    let service = GTLRYouTubeService()

    let disposeBag = DisposeBag()
    var searchResults: Variable<[Video]> = Variable([Video]())
    var searching: Variable<Bool> = Variable(false)

    // MARK: Initialization
    override init() {
        super.init()
                GoogleActions.sharedInstance.currentUser.asObservable()
                    .filter {[unowned self] user in
                        if user == nil { self.service.authorizer = nil }
                        return user != nil
                    }
                    .subscribe(onNext: {_ in
                        self.service.authorizer = GoogleActions.sharedInstance
                            .getUser().authentication.fetcherAuthorizer()
                    })
                    .disposed(by: disposeBag)
    }

    // MARK: Public Methods
    func searchByPhrase(phrase: String) {
        if !phrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
            query.q = phrase
            query.type = "video"
            query.maxResults = 50
            if service.authorizer != nil {
                searching.value = !searching.value
                service.shouldFetchNextPages = false
                service.executeQuery(query,
                                     delegate: self,
                                     didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
            }
        }
    }
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject response: GTLRYouTube_SearchListResponse,
                                       error: NSError?) {
        if error != nil {
            print(error.debugDescription)
            return
        }
        if let results = response.items, !results.isEmpty {
            searchResults.value = [Video]()
            for result in results {
                let photoUrl = URL(string: (result.snippet?.thumbnails?.defaultProperty?.url)!)
                let data = try? Data(contentsOf: photoUrl!)
                var tempThumbnail = UIImage(named: "defaultPhoto")
                if data != nil {
                    tempThumbnail = UIImage(data: data!)
                }
                let tempVideo = Video(identifier: (result.identifier?.videoId)!,
                                      title: result.snippet!.title!,
                                      uploader: (result.snippet?.channelTitle)!,
                                      thumbnail: tempThumbnail)
                searchResults.value.append(tempVideo!)
            }
        }
        searching.value = !searching.value
    }
}
