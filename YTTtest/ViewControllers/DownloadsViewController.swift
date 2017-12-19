//
//  DownloadsViewController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 29/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DownloadsViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    //var downloadsArray = Variable<[Video]>([])

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    func setupTableView() {
//        Downloads.sharedInstance.downloadsArray.asObservable()
//            .subscribe(onNext: { [unowned self]updatedArray in
//                self.downloadsArray.value = updatedArray
//            })
//            .disposed(by: disposeBag)
        Downloads.sharedInstance.downloadsArray.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "DownloadTableViewCell")) { _, model, cell in
                let cellToUse = cell as? DownloadTableViewCell
                cellToUse?.initCell(video: model)
            }
            .disposed(by: disposeBag)
//        downloadsArray.asObservable()
//            .bind(to: tableView.rx.items(cellIdentifier: "DownloadTableViewCell")) { index, model, cell in
//                let cellToUse = cell as? DownloadTableViewCell
//                cellToUse?.initCell(video:model)
//            }
//            .disposed(by: disposeBag)
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
