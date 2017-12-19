//
//  UIAlerts.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 08/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UIAlert {

    class func showSimpleActionSheet(_ viewController: UIViewController,
                                     title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(actionOK)
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showSimpleAlert(_ viewController: UIViewController,
                               title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(actionOK)
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showSimpleErrorAlert(_ viewController: UIViewController,
                                    title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(actionOK)
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showAlertWithResponse(_ viewController: UIViewController,
                                     title: String, message: String,
                                     onOKPressed completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: {_ in
                                        completion()
        })
        let actionCANCEL = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(actionOK)
        alert.addAction(actionCANCEL)
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showAlertWithInput(_ viewController: UIViewController, title: String,
                                  message: String, placeHolder: String,
                                  onSuccess completion: @escaping (_ textInput: String) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: {_ in
                                        completion(alert.textFields![0].text!)
        })
        let actionCANCEL = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alert.addTextField { (textField) in
            textField.placeholder = placeHolder
        }
        alert.addAction(actionOK)
        alert.addAction(actionCANCEL)
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showActionSheetWithProvidedPicker(_ viewController: UIViewController,
                                                 picker: UIPickerView,
                                                 title: String, message: String,
                                                 onSuccess completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: {_ in
                                        completion()
        })
        let actionCANCEL = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alert.view.addSubview(picker)
        alert.addAction(actionOK)
        alert.addAction(actionCANCEL)
        viewController.present(alert, animated: true, completion: nil)
    }
}
