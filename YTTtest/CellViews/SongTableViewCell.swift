//
//  VideoTableViewCell.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 14/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import ESTMusicIndicator
import RxSwift

class SongTableViewCell: UITableViewCell {

    // MARK: Properties
    lazy var indicator: ESTMusicIndicatorView = ESTMusicIndicatorView.init(frame: CGRect(x: 80.0,
                                                                                         y: 30.0,
                                                                                         width: 20.0,
                                                                                         height: 15.0))
    let disposeBag = DisposeBag()
    let musicPlayer = MyMusicPlayer.sharedInstance

    // MARK: Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator = (viewWithTag(999) as! ESTMusicIndicatorView)

        musicPlayer.lastRemoteControlEvent.asObservable()
            .subscribe(onNext: { state in
                if self.musicPlayer.tracks.count < 1 { return }
                if (self.accessibilityIdentifier?.elementsEqual(self.musicPlayer.getCurrentTrackInfo().identifier))! {
                    self.changeIndicatorState(state: state)
                }
            })
        .disposed(by: disposeBag)

        imageView?.frame = CGRect(x: 20.0, y: bounds.height / 2 - 24, width: 48, height: 48)
        imageView?.layer.cornerRadius = 3
        separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)

        textLabel?.textColor = UIColor.white
        detailTextLabel?.textColor = UIColor.white
    }
    override func prepareForReuse() {
        loadIndicatorState()
    }

    // MARK: Public Methods
    func initCell(track: Track) {
        textLabel?.text = track.title
        detailTextLabel?.text = track.uploader
        imageView?.image = track.thumbnail
        accessibilityIdentifier = track.identifier

        indicator.tintColor = UIColor.lightGray
        indicator.tag = 999
        indicator.sizeToFit()
        indicator.state = .stopped
        contentView.addSubview(indicator)
    }

    // MARK: Private Methods
    private func changeIndicatorState(state: RemoteControlEvent) {
        switch state {
        case .playing:
            indicator.tintColor = UIColor.magenta
            indicator.state = .playing
        case .pause:
            indicator.tintColor = UIColor.lightGray
            indicator.state = .paused
        case .stop:
            indicator.state = .stopped
        }
    }
    private func loadIndicatorState() {
        if(self.accessibilityIdentifier?.elementsEqual(self.musicPlayer.getCurrentTrackInfo().identifier))! {
            if MyMusicPlayer.sharedInstance.player.isPlaying {
                indicator.state = .playing
            } else {
                indicator.state = .paused
            }
        } else {
            indicator.state = .stopped
        }
    }
}
