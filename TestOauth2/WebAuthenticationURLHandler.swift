//
//  WebAuthenticationURLHandler.swift
//  TestOauth2
//
//  Created by Anton Glezman on 06/08/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation
import AuthenticationServices
import OAuthSwift

final class WebAuthenticationURLHandler: OAuthSwiftURLHandlerType {
    var webAuthSession: ASWebAuthenticationSession!
    let callbackUrlScheme: String
    
    init(callbackUrlScheme: String) {
        self.callbackUrlScheme = callbackUrlScheme
    }
    
    public func handle(_ url: URL) {
        webAuthSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackUrlScheme,
            completionHandler: { callback, error in
                guard error == nil, let successURL = callback else {
                    let msg = error?.localizedDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let urlString = "\(self.callbackUrlScheme):?error=\(msg ?? "UNKNOWN")"
                    let url = URL(string: urlString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
                UIApplication.shared.open(successURL, options: [:], completionHandler: nil)
        }
        )
        _ = webAuthSession.start()
    }
}
