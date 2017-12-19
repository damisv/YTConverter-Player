//
//  AppDelegate.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 10/11/2017.
//  Copyright © 2017 Damian. All rights reserved.
//
import Google
import GoogleSignIn
import GoogleAPIClientForREST
import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    // MARK: Scopes Google
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        GIDSignIn.sharedInstance().scopes = scopes
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        let annotation = options[.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        print(identifier)
    }
}
