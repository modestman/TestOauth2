//
//  ViewController.swift
//  TestOauth2
//
//  Created by Anton Glezman on 05/08/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {

    private enum Constants {
        static let callbackScheme = "com.googleusercontent.apps.1003274482661-bcv50ot3kkfdlv86m71tvub345oouak1"
        static let consumerKey = "1003274482661-bcv50ot3kkfdlv86m71tvub345oouak1.apps.googleusercontent.com"
        static let authorizeUrl = "https://accounts.google.com/o/oauth2/v2/auth"
        static let accessTokenUrl = "https://www.googleapis.com/oauth2/v4/token"
        static let responseType = "code"
        static let scope = "email profile https://www.googleapis.com/auth/calendar"
    }
    
    private var oauth: OAuth2Swift!
    private var credentials: OAuthSwiftCredential?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oauth = OAuth2Swift(
            consumerKey: Constants.consumerKey,
            consumerSecret: "",
            authorizeUrl: Constants.authorizeUrl,
            accessTokenUrl: Constants.accessTokenUrl,
            responseType: Constants.responseType)
        oauth.authorizeURLHandler = WebAuthenticationURLHandler(callbackUrlScheme: Constants.callbackScheme)
    }

    @IBAction func logIn(_ sender: Any) {
        let codeVerifier = OIDTokenUtilities.generateCodeVerifier() ?? ""
        let codeChallenge = OIDTokenUtilities.codeChallengeS256(forVerifier: codeVerifier) ?? ""
        oauth.authorize(
            withCallbackURL: "\(Constants.callbackScheme):/oauth2callback",
            scope: Constants.scope,
            state: "TEST",
            codeChallenge: codeChallenge,
            codeVerifier: codeVerifier,
            completionHandler: { [unowned self] result in
                switch result {
                case .success(let success):
                    self.credentials = success.credential
                    print(success.credential.oauthToken)
                case .failure(let error):
                    print(error)
                }
        })
    }
    
    @IBAction func updateToken(_ sender: Any) {
        guard let credentials = self.credentials else { return }
        oauth.renewAccessToken(
        withRefreshToken: credentials.oauthRefreshToken) { [unowned self] result in
            switch result {
            case .success(let success):
                self.credentials = success.credential
                print(success.credential.oauthToken)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

