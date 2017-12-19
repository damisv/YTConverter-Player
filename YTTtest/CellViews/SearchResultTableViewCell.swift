//
//  SearchResultTableViewCell.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 14/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRect(x: 20.0, y: bounds.height / 2 - 24, width: 48, height: 48)
        imageView?.layer.cornerRadius = 3
        separatorInset = UIEdgeInsets(top: 0, left: textLabel!.frame.origin.x, bottom: 0, right: 0)
    }
}
