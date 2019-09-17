//
//  GithubViewController.swift
//  TestOauth2
//
//  Created by Anton Glezman on 17/09/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import AuthenticationServices
import UIKit

class GithubViewController: UIViewController {
    
    private enum Constants {
        static let callbackScheme = "github.oauth"
        static let redirectUrl = "github.oauth://redirect"
        static let clientId = "9a81dda9e43828b9dc6b"
        static let clientSecret = "1b2a3955ee875937c0827ea42192361562aff908"
        static let authorizeUrl = "https://github.com/login/oauth/authorize"
        static let accessTokenUrl = "https://github.com/login/oauth/access_token"
        static let responseType = "code"
        static let scope = "user"
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  
    @IBAction func login(_ sender: Any) {
        let authUrl = makeAuthorizeUrl()
        // Создаем сессию
        let webAuthSession = ASWebAuthenticationSession(
            url: authUrl,
            callbackURLScheme: Constants.callbackScheme) { [weak self] (callbackUrl, error) in
                guard let url = callbackUrl, error == nil else { return }
                // достаем из callbackUrl code
                let components = URLComponents(string: url.absoluteString)
                if let codeItem = components?.queryItems?.first(where: { $0.name == Constants.responseType }),
                   let code = codeItem.value {
                    self?.exchangeCodeToToken(code)
                }
        }
        webAuthSession.presentationContextProvider = self // только для iOS 13
        webAuthSession.start()
    }
    
    // URL который будет показан в WebView, где пользователь авторизуется
    private func makeAuthorizeUrl() -> URL {
        let clientId = URLQueryItem(name: "client_id", value: Constants.clientId)
        let redirectUri = URLQueryItem(name: "redirect_uri", value: Constants.redirectUrl)
        let scope = URLQueryItem(name: "scope", value: Constants.scope)
        let state = URLQueryItem(name: "state", value: "Test")
        var components = URLComponents(string: Constants.authorizeUrl)!
        components.queryItems = [clientId, redirectUri, scope, state]
        return components.url!
    }

    // URL для получения access_token по коду
    private func makeTokenUrl(code: String) -> URL {
        let clientId = URLQueryItem(name: "client_id", value: Constants.clientId)
        let clientSecret = URLQueryItem(name: "client_secret", value: Constants.clientSecret)
        let code = URLQueryItem(name: "code", value: code)
        let state = URLQueryItem(name: "state", value: "Test")
        var components = URLComponents(string: Constants.accessTokenUrl)!
        components.queryItems = [clientId, clientSecret, code, state]
        return components.url!
    }
    
    // Запрос для получения access_token
    private func exchangeCodeToToken(_ code: String) {
        var request = URLRequest(url: makeTokenUrl(code: code))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let accessToken = json?["access_token"] as? String
            DispatchQueue.main.async {
                self?.nameLabel.text = accessToken
            }
        }
        task.resume()
    }
    
}


extension GithubViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
