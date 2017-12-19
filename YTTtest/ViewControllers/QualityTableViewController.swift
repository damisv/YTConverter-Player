//
//  QualityTableViewController.swift
//  YTTtest
//
//  Created by Damian Anchidin on 29/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class QualityTableViewController: UITableViewController {

    let disposeBag = DisposeBag()
    let qualities = Observable<[String]>.just(["highest", "high", "medium", "low", "lowest"])

    override func viewDidLoad() {
        super.viewDidLoad()
        qualities.bind(to: tableView.rx.items(cellIdentifier: "DownloadQualityCell")) { _, model, cell in
            cell.textLabel?.text = model
            if model.elementsEqual("low") { cell.accessoryType = .checkmark }
        }
        .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            })
        .disposed(by: disposeBag)
        tableView.rx.itemDeselected
            .subscribe(onNext: { indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            })
        .disposed(by: disposeBag)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
