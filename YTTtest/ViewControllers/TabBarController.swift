//
//  TabBarController.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 23/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import MediaPlayer
import GoogleSignIn
import RxSwift
import RxCocoa
import os.log
import RAMAnimatedTabBarController

@objc protocol TabBarSwitcher {
    func handleSwipes(sender: UISwipeGestureRecognizer)
}

extension TabBarSwitcher where Self: UITabBarController {
    func initSwipe(direction: UISwipeGestureRecognizerDirection) {
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(TabBarSwitcher.handleSwipes(sender:))
        )
        swipe.direction = direction
        self.view.addGestureRecognizer(swipe)
    }
}

class TabBarController: RAMAnimatedTabBarController,
                        UITabBarControllerDelegate,
                        TabBarSwitcher {

    // MARK: Properties
    override var canBecomeFirstResponder: Bool {return true}
    private let musicPlayer = MyMusicPlayer.sharedInstance

    let disposeBag = DisposeBag()

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initSwipe(direction: .left)
        initSwipe(direction: .right)

        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        changeDownloadsTabBarBadge()

        MPNowPlayingInfoCenter.initialize()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Protocol Methods
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if self.selectedIndex < (self.tabBar.items?.count)! {
                self.selectedIndex += 1
                //self.setSelectIndex(from: temp, to: self.selectedIndex)
            }
        } else if sender.direction == .right {
            if self.selectedIndex > 0 {
                self.selectedIndex -= 1
                //self.setSelectIndex(from: temp, to: self.selectedIndex)
            }
        }
    }

    // MARK: NowPlayingInfoCenter Remote Control
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEventType.remoteControl {
            switch event!.subtype {
            case .none:
                return
            case .motionShake:
                return
            case .remoteControlPlay:
                musicPlayer.play()
            case .remoteControlPause:
                musicPlayer.pause()
            case .remoteControlStop:
                musicPlayer.stop()
            case .remoteControlTogglePlayPause:
                musicPlayer.togglePlayPause()
            case .remoteControlNextTrack:
                musicPlayer.nextTrack()
            case .remoteControlPreviousTrack:
                musicPlayer.previousSong()
            case .remoteControlBeginSeekingBackward,
                 .remoteControlEndSeekingBackward,
                 .remoteControlBeginSeekingForward,
                 .remoteControlEndSeekingForward:
                return
            }
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: Private Methods
    func changeDownloadsTabBarBadge() {
        Downloads.sharedInstance.downloadsArray.asObservable()
            .observeOn(MainScheduler.instance)
            .do(onNext: {[unowned self] updatedArray in
                if updatedArray.count > 0 {
                    self.tabBar.items![4].badgeValue = "\(updatedArray.count)"
                    self.tabBar.items![4].badgeColor = UIColor.red
                } else {
                    self.tabBar.items![4].badgeValue = nil
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
}
extension TabBarController: GIDSignInDelegate,
GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            var tempUser = User(user: user)
            let savedUser = AppFileManager.load(fromFile: AppFileManager.UserArchiveURL)! as [User]
            if savedUser.count > 0 { tempUser = savedUser.first! }
            print(tempUser.user.profile.email)
        } else {
            print("\(error.localizedDescription)")
            return
        }
        GoogleActions.sharedInstance.isSignedIn()
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GoogleActions.sharedInstance.isSignedIn()
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
