//
//  SettingsTableViewController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 29/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleSignIn

class SettingsTableViewController: UITableViewController {

    // MARK: Properties
    @IBOutlet weak var googleSignOutButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var keepDownloadHistory: UISwitch!

    let disposeBag = DisposeBag()
    let googleActions = GoogleActions.sharedInstance

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        googleActions.signedIn.asObservable()
            .subscribe(onNext: { state in
                self.googleSignOutButton.isHidden = !state
                self.googleSignInButton.isHidden = state
            })
            .disposed(by: disposeBag)
        googleSignInButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.googleActions.signIn()
            })
            .disposed(by: disposeBag)
        googleSignOutButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.googleActions.signOut()
            })
            .disposed(by: disposeBag)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private Methods
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
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
