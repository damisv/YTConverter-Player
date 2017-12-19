//
//  PlaylistViewController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 27/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import ESTMusicIndicator

class PlaylistViewController: UIViewController {

    // MARK: Properties
    var playlist: Playlist!

    @IBOutlet weak var playlistSongsTotalLabel: UILabel!
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var playlistThumbnail: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Private Methods
    private func reloadData() {
        playlistTitleLabel.text = playlist.title
        playlistSongsTotalLabel.text = String(describing: playlist.tracks!.count)
        navigationItem.title = playlist.title
        if playlist.tracks!.count > 0 {
            playlistThumbnail.image = playlist.tracks![0].thumbnail
        }
        tableView.reloadData()
    }

    // MARK: Initializations
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlaylistViewController: UITableViewDataSource,
                                    UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistSongTableViewCell", for: indexPath)

        let song = playlist.tracks![indexPath.row]
        cell.imageView?.image = song.thumbnail
        cell.textLabel?.text = song.title
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = song.uploader
        cell.detailTextLabel?.textColor = UIColor.white
        cell.accessibilityIdentifier = song.identifier

        let indicator = ESTMusicIndicatorView.init(frame: CGRect(x: 80.0, y: 30.0, width: 20.0, height: 15.0))
        indicator.tintColor = .red
        indicator.tag = 999
        indicator.sizeToFit()
        indicator.state = .stopped
        cell.contentView.addSubview(indicator)

        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        cell.selectedBackgroundView = selectionView

        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share") { _, _ in
            print("share button tapped")
        }
        share.backgroundColor = .orange
        return [share]
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
