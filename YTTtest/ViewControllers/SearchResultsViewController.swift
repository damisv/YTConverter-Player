//
//  SearchVideos.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 14/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftOverlays
import ToastSwiftFramework

class SearchResultsViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    private let googleActions = GoogleActions.sharedInstance
    private let youtubeActions = YouTubeActions.sharedInstance

    let searchController = UISearchController(searchResultsController: nil)

    var searchResults = [Video]()
    var signedIn: Bool = false

    let disposeBag = DisposeBag()
    let searchPhrase = Variable<String?>(nil)

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupNavBar()
        setupObservers()
        setupSearchBarObservers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Private Methods
    private func showLoader() {
        self.showWaitOverlayWithText("Searching ...")
    }
    private func hideLoader() {
        self.removeAllOverlays()
    }
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Videos"
        UITextField.appearance(whenContainedInInstancesOf:
                                [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    private func setupObservers() {
        youtubeActions.searchResults.asObservable()
            .subscribe(onNext: { [unowned self] updatedArray in
                self.searchResults = updatedArray
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        youtubeActions.searching.asObservable()
            .subscribe(onNext: {[unowned self] state in
                state ? self.showLoader() : self.hideLoader()
            })
            .disposed(by: disposeBag)
        googleActions.signedIn.asObservable()
            .subscribe(onNext: {[unowned self] state in
                self.signedIn = state
            })
            .disposed(by: disposeBag)
    }
    private func setupSearchBarObservers() {
        searchController.searchBar.rx.text.asDriver()
            //.throttle(1.5, scheduler: MainScheduler.instance)
            .drive(searchPhrase)
            .disposed(by: disposeBag)
        searchController.searchBar.rx.searchButtonClicked.asDriver()
            .drive(onNext: {[unowned self]_ in
                if self.signedIn {
                    self.youtubeActions.searchByPhrase(phrase: self.searchPhrase.value!)
                } else {
                    self.view.makeToast("You are not signed in.Check Settings tab.")
                }
            })
            .disposed(by: disposeBag)
    }
}

extension SearchResultsViewController: UITableViewDataSource,
                                        UITableViewDelegate {
    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separator = UIView(frame: CGRect(x: 0, y: 0,
                                             width: tableView.bounds.size.width,
                                             height: 1 / UIScreen.main.scale))
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        separator.autoresizingMask = .flexibleWidth
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 2))
        view.addSubview(separator)
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell",
                                                 for: indexPath) as! SearchResultTableViewCell
        let tempVideo = searchResults[indexPath.row]
        cell.imageView?.image = tempVideo.thumbnail
        cell.textLabel?.text = tempVideo.title
        cell.detailTextLabel?.text = tempVideo.uploader
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToPlaylist = UITableViewRowAction(style: .normal,
                                                 title: "Add To Playlist") { _, _ in
        }
        addToPlaylist.backgroundColor = .lightGray
        let download = UITableViewRowAction(style: .normal,
                                            title: "Download") { _, index in
            self.searchResults[index.row].downloadConvertedVideo()
            UIAlert.showSimpleActionSheet(self, title: "Downloading shortly...",
                                          message: "Check Downloads tab for progress.")
        }
        download.backgroundColor = .blue
        return [addToPlaylist, download]
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
