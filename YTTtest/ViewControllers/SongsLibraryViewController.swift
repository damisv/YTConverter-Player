//
//  VideoTableViewController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 20/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import AVFoundation
import os.log
import ESTMusicIndicator
import ToastSwiftFramework
import RxSwift
import RxCocoa

extension SongsLibraryViewController: UISearchResultsUpdating {
    // MARK: UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class SongsLibraryViewController: UIViewController {

    // MARK: Private Properties
//    private var tracks = Observable<[Track]>.just([])
    var tracks: [Track] = [Track]()
    private var playlists: [Playlist] = [Playlist]()

    let disposeBag = DisposeBag()

    var selectedPlaylist: Playlist?

    var myMusicPlayer: MyMusicPlayer = MyMusicPlayer.sharedInstance

    let searchController = UISearchController(searchResultsController: nil)
    var filteredTracks = [Track]()

    @IBOutlet weak var tracksTotal: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Private instance methods
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTracks = tracks.filter({(track: Track) -> Bool in
            return track.title.lowercased().contains(searchText.lowercased())
        })
        tracksTotal.text = "0 tracks"
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    // MARK: Private methods
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search through library"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .defaultTextAttributes = [
                NSAttributedStringKey
                    .foregroundColor
                    .rawValue: UIColor.white
        ]
    }

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupObservers()
    }
    func setupObservers() {
        TrackLibrary.sharedInstance.tracks.asObservable()
            .subscribe(onNext: {[unowned self] tracks in
                self.tracks = tracks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        .disposed(by: disposeBag)
        TrackLibrary.sharedInstance.playlists.asObservable()
            .subscribe(onNext: {[unowned self] playlists in
                self.playlists = playlists
            })
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
//        tracks.bind(to: tableView.rx.items(cellIdentifier: "SongTableViewCell")) { index, track, cell in
//            cell.imageView?.image = track.thumbnail
//            cell.textLabel?.text = track.title
//            cell.textLabel?.textColor = UIColor.white
//            cell.detailTextLabel?.text = track.uploader
//            cell.detailTextLabel?.textColor = UIColor.white
//        }
//        .disposed(by: disposeBag)
    }
}
extension SongsLibraryViewController: UITableViewDataSource,
                                      UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTracks.count
        }
        return tracks.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell",
                                                 for: indexPath) as! SongTableViewCell
        let tempTrack: Track
        if isFiltering() {
            tempTrack = filteredTracks[indexPath.row]
            tracksTotal.text = "\(filteredTracks.count) " + ((filteredTracks.count==1) ? "track" : "tracks")
        } else {
            tempTrack = tracks[indexPath.row]
            tracksTotal.text = "\(tracks.count) " + ((tracks.count==1) ? "track" : "tracks")
        }
        cell.initCell(track: tempTrack)
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .normal, title: "\u{25B6}\nPlay") { _, index in
            self.myMusicPlayer.playSong(identifier: self.tracks[index.row].identifier)
            self.showPopUpToolbar(track: self.tracks[index.row])
//            let cell = tableView.cellForRow(at: index)
//            let indicator:ESTMusicIndicatorView = cell?.viewWithTag(999) as! ESTMusicIndicatorView
//            indicator.state = .playing
        }
        play.backgroundColor = Utils.hexStringToUIColor(hex: "#7C557D")
        let addToPlaylist = UITableViewRowAction(style: .normal, title: "Add to Playlist") { _, index in
            if self.playlists.count == 0 {
                UIAlert.showAlertWithInput(self, title: "No Playlist Available",
                                           message: "Create one? Enter name below",
                                           placeHolder: "New Playlist",
                                           onSuccess: { playlistName in
                    let temp = Playlist(identifier: String(describing: Utils.randomAlphaNumericGenerator(length: 12)),
                                        title: playlistName,
                                        tracks: [self.tracks[index.row]])
                    temp?.savePlaylist()
                })
            } else {
                self.addToPlaylist(track: self.tracks[index.row])
            }
        }
        addToPlaylist.backgroundColor = .lightGray
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { _, index in
            self.deleteTrack(track: self.tracks[index.row])
        }
        delete.backgroundColor = Utils.hexStringToUIColor(hex: "#7a0909")
        return [ play, addToPlaylist, delete]
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    private func deleteTrack(track: Track) {
        UIAlert.showAlertWithResponse(self, title: "Delete?", message: "\(track.title)", onOKPressed: {
            track.deleteTrack(
                onSuccess: {
                    self.view.makeToast("Track Deleted Successfully!")
            },
                onFail: {
                    UIAlert.showAlertWithResponse(self, title: "Delete Failed", message: "Retry ?", onOKPressed: {
                        self.deleteTrack(track: track)
                    })
            })
        })
    }
    // MARK: Private Methods
    private func addToPlaylist(track: Track) {
        let pickerFrame = CGRect(x: 5, y: 20, width: 260, height: 160)
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        var tempPlaylistSelected = [Playlist]()
        let data = Observable.of(playlists)
        data
            .bind(to: picker.rx.itemTitles) { _, playlist in
                return "\(playlist.title)"
            }
            .disposed(by: disposeBag)
        picker.rx.modelSelected(Playlist.self)
            .subscribe(onNext: { models in
                tempPlaylistSelected = models
            })
            .disposed(by: disposeBag)
        UIAlert.showActionSheetWithProvidedPicker(self, picker: picker,
                                                  title: "Select Playlist",
                                                  message: "Select a playlist to add to: \n\n\n\n\n",
                                                  onSuccess: {
                                                    track.addToPlaylist(playlistID: tempPlaylistSelected[0].identifier)
                                                })
    }
    private func showPopUpToolbar(track: Track) {
        let popupContentController = storyboard?.instantiateViewController(
                withIdentifier: "MusicPlayerController") as! MusicPlayerController
        navigationController?.popupBar
            .marqueeScrollEnabled = true
        navigationController?.popupBar
            .progressViewStyle = .top
        popupContentController.popupItem
            .accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
        tabBarController?.popupContentView
            .popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
        popupContentController.trackTitle = track.title
        popupContentController.uploaderTitle  = track.uploader
        popupContentController.artwork = track.thumbnail!
        tabBarController?.presentPopupBar(withContentViewController: popupContentController,
                                                    animated: true, completion: nil)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
