//
//  PlaylistsTableViewController.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 22/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import MediaPlayer
import RxSwift
import RxCocoa
import ToastSwiftFramework

class PlaylistsViewController: UIViewController {

    // MARK: Properties
    var myPlaylists: [Playlist] = [Playlist]()
    var myMusicPlayer: MyMusicPlayer = MyMusicPlayer.sharedInstance

    let disposeBag = DisposeBag()

    @IBOutlet weak var addPlaylistButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        setupObservers()
        setupNavBar()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private Methods
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupObservers() {
        TrackLibrary.sharedInstance.playlists.asObservable()
            .subscribe(onNext: {[unowned self] playlists in
                self.myPlaylists = playlists
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        addPlaylistButton.rx.tap.asDriver()
            .drive(onNext: {[unowned self] _ in
                self.addToPlaylist()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PlaylistViewController
        guard let cell = sender as? UITableViewCell else {
            return
        }
        destinationVC.playlist = myPlaylists[cell.tag]
    }
}

extension PlaylistsViewController: UITableViewDataSource,
                                    UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPlaylists.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath)

        let playlist = myPlaylists[indexPath.row]
        var temp = UIImage(named: "defaultPhoto")
        if playlist.tracks!.count > 0 {
            temp = playlist.tracks![0].thumbnail
        }
        cell.imageView?.image = temp
        cell.textLabel?.text = playlist.title
        cell.textLabel?.textColor = UIColor.white
        var pluralTemp = "tracks"
        if playlist.tracks?.count==1 {
            pluralTemp = "track"
        }
        cell.detailTextLabel?.text = "\(playlist.tracks!.count) \(pluralTemp)"
        cell.detailTextLabel?.textColor = UIColor.white

        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        cell.selectedBackgroundView = selectionView

        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .normal, title: "\u{25B6}\nPlay") { _, index in
            self.myMusicPlayer.playPlaylist(identifier: self.myPlaylists[index.row].identifier)
            self.showPopUpToolbar()
        }
        play.backgroundColor = Utils.hexStringToUIColor(hex: "#7C557D")
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { _, index in
            self.deletePlaylist(playlist: self.myPlaylists[index.row])
        }
        delete.backgroundColor = Utils.hexStringToUIColor(hex: "#7a0909")
        return self.myPlaylists[indexPath.row].tracks!.count>0 ? [play, delete] : [delete]
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.tag = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "PlaylistViewSegue", sender: cell)
    }

    // MARK: Private Methods
    private func addToPlaylist() {
        UIAlert.showAlertWithInput(self, title: "Create new playlist",
                                   message: "Enter an descriptive name",
                                   placeHolder: "New Playlist", onSuccess: {name in
            let tempPlaylist = Playlist(identifier: String(describing: Utils.randomAlphaNumericGenerator(length: 12)),
                                        title: name, tracks: [])
            tempPlaylist?.savePlaylist()
        })
    }
    private func deletePlaylist(playlist: Playlist) {
        UIAlert.showAlertWithResponse(self, title: "Delete?", message: "\(playlist.title)", onOKPressed: {
            playlist.deletePlaylist(
                onSuccess: {
                    self.view.makeToast("Playlist Deleted Successfully!")
            },
                onFail: {
                    UIAlert.showAlertWithResponse(self, title: "Delete Failed", message: "Retry ?", onOKPressed: {
                        self.deletePlaylist(playlist: playlist)
                    })
            })
        })
    }
    private func showPopUpToolbar() {
        let popupContentController = storyboard?.instantiateViewController(withIdentifier: "MusicPlayerController") as! MusicPlayerController
        let track = MyMusicPlayer.sharedInstance.getCurrentTrackInfo()
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
}
