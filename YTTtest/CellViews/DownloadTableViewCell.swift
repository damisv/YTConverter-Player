//
//  DownloadTableViewCell.swift
//  YTTtest
//
//  Created by Damian Anchidin on 29/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift

class DownloadTableViewCell: UITableViewCell {

    // MARK: Properties
    var disposeBag = DisposeBag()
    private var video: Video?

    // MARK: Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        initProgressObserver()
    }
    // MARK: Public Methods
    func initCell(video: Video) {
        self.video = video
        textLabel?.text = video.title
        imageView?.image = video.thumbnail
        initProgressObserver()
        textLabel?.textColor = UIColor.white
        detailTextLabel?.textColor = UIColor.white
    }

    // MARK: Private Methods
    private func initProgressObserver() {
        video?.downloadProgress.asObservable()
            .subscribe(onNext: { [unowned self] progress in
                print(progress)
                self.detailTextLabel?.text = "\(progress)"
            })
            .disposed(by: disposeBag)
    }
}
