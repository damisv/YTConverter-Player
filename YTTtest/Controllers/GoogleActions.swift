//
//  GoogleActions.swift
//  YTTtest
//
//  Created by Edward Dumitriu on 07/12/2017.
//  Copyright © 2017 Damian. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

class GoogleActions {

    static let sharedInstance = GoogleActions()
    var signedIn: Variable<Bool> = Variable(false)
    var currentUser = Variable(GIDSignIn.sharedInstance().currentUser)

    init() {}

    func isSignedIn() {
        if GIDSignIn.sharedInstance().currentUser != nil {
            signedIn.value = true
            currentUser.value = GIDSignIn.sharedInstance().currentUser
        } else {
            signedIn.value = false
            currentUser.value = nil
        }
    }
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    func signOut() {
        GIDSignIn.sharedInstance().disconnect()
    }
    func getUser() -> GIDGoogleUser {
        return GIDSignIn.sharedInstance().currentUser
    }
}
