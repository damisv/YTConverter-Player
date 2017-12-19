//
//  MusicPlayerController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 27/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import LNPopupController
import AVFoundation
import MediaPlayer
import MarqueeLabel
import RxSwift

class MusicPlayerController: UIViewController {

    // MARK: Properties
    var observable: NSKeyValueObservation?
    let disposeBag = DisposeBag()

    private var musicPlayer = MyMusicPlayer.sharedInstance

    let accessibilityDateComponentsFormatter = DateComponentsFormatter()

    @IBOutlet weak var songNameLabel: MarqueeLabel!
    @IBOutlet weak var uploaderNameLabel: UILabel!
    @IBOutlet weak var songThumbnail: UIImageView!
    @IBOutlet weak var volume: UISlider!
    @IBOutlet weak var songProgress: UIProgressView!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    var trackTitle: String = "" {
        didSet {
            if isViewLoaded {
                songNameLabel.text = trackTitle
                songNameLabel.restartLabel()
            }
            popupItem.title = trackTitle
        }
    }
    var uploaderTitle: String = "" {
        didSet {
            if isViewLoaded {
                uploaderNameLabel.text = uploaderTitle
            }
            popupItem.subtitle = uploaderTitle
        }
    }
    var artwork: UIImage = UIImage() {
        didSet {
            if isViewLoaded {
                songThumbnail.image = artwork
            }
            popupItem.image = artwork
            popupItem.accessibilityImageLabel = NSLocalizedString("Artwork", comment: "")
        }
    }

    // MARK: Public Methods
    @objc func updateProgressView() {
        if self.musicPlayer.player.isPlaying {
            self.songProgress.setProgress(Float(
                (self.musicPlayer.player.currentTime)/(self.musicPlayer.player.duration)), animated: true)
        }
    }

    // MARK: Private Methods
    private func setupTitleMarqueeLabel() {
        songNameLabel.type = .continuous
        songNameLabel.speed = .rate(80)
        songNameLabel.animationCurve = .easeInOut
        songNameLabel.fadeLength = 10.0
        songNameLabel.leadingBuffer = 30.0
        songNameLabel.trailingBuffer = 20.0
        songNameLabel.triggerScrollStart()
    }
    private func setupToolbarButton() {
        let togglePlayPause = UIBarButtonItem(
            image: UIImage(named: "pause"),
            style: .plain,
            target: self,
            action: #selector(popupBarTogglePlayPausePressed(sender:))
        )
        togglePlayPause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
        togglePlayPause.tintColor = Utils.hexStringToUIColor(hex: "#7C557D")
        let next = UIBarButtonItem(
            image: UIImage(named: "fastForward"),
            style: .plain,
            target: self,
            action: #selector(popupBarFastForwardPressed(sender:))
        )
        next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
        next.tintColor = Utils.hexStringToUIColor(hex: "#7C557D")
        self.popupItem.leftBarButtonItems = [ togglePlayPause ]
        self.popupItem.rightBarButtonItems = [ next ]
    }
    private func changeStateTogglePlayPauseButton(state: String) {
        popupItem.leftBarButtonItems![0].image = UIImage(named: state)
        playButton?.setImage(UIImage(named: state), for: .normal)
    }
    private func initializeViewData() {
        volume.value = getSystemVolume()
        songNameLabel.text = trackTitle
        uploaderNameLabel.text = uploaderTitle
        songThumbnail.image = artwork
    }
    private func setSystemVolume(volume: Float) {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                let slider = view as! UISlider
                slider.setValue(volume, animated: false)
            }
        }
    }
    private func getSystemVolume() -> Float {
        return MyMusicPlayer.audioSession.outputVolume
    }

    // MARK: Actions
    @objc func popupBarTogglePlayPausePressed(sender: UIBarButtonItem) {
        musicPlayer.togglePlayPause()
    }
    @objc func popupBarFastForwardPressed(sender: UIBarButtonItem) {
        musicPlayer.nextTrack()
    }

    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupToolbarButton()
        accessibilityDateComponentsFormatter.unitsStyle = .spellOut
        setupTrackObserver()
        setupRemoteControlObserver()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewData()
        setupTitleMarqueeLabel()
        volume.rx.value
            .bind { value in
                self.setSystemVolume(volume: value)
            }
            .disposed(by: disposeBag)
        playButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.musicPlayer.togglePlayPause()
            })
            .disposed(by: disposeBag)
        forwardButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.musicPlayer.nextTrack()
            })
            .disposed(by: disposeBag)
        backwardButton.rx.tap.asDriver()
            .drive(onNext: {
                self.musicPlayer.previousSong()
            })
            .disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        do {
            try MyMusicPlayer.audioSession.setActive(true)
            self.observable = MyMusicPlayer.audioSession.observe(\.outputVolume) {(audioV, _) in
                self.volume.setValue(audioV.outputVolume, animated: true)
            }
            Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                 selector: #selector(updateProgressView),
                                 userInfo: nil, repeats: true)
        } catch {
            print("Failed Observing")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // RX Setup
    private func setupTrackObserver() {
        musicPlayer.currentTrack.asObservable()
            .subscribe(onNext: { track in
                self.trackTitle = track.title
                self.uploaderTitle = track.uploader
                self.artwork = track.thumbnail!
            })
            .disposed(by: disposeBag)
    }
    private func setupRemoteControlObserver() {
        musicPlayer.lastRemoteControlEvent.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .playing:
                    self.changeStateTogglePlayPauseButton(state: "pause")
                case .pause:
                    self.changeStateTogglePlayPauseButton(state: "play")
                case .stop:
                    return
                }
            })
            .disposed(by: disposeBag)
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
