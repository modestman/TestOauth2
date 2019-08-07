//
//  Authorizer.swift
//  TestOauth2
//
//  Created by Anton Glezman on 06/08/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation
import GTMSessionFetcher
import OAuthSwift

/// An authorizer adds user authentication headers to the request as needed.
final class Authorizer: NSObject, GTMFetcherAuthorizationProtocol {
    
    struct Constant {
        static let AuthorizationHeader = "Authorization"
    }
    
    private(set) var credentials: OAuthSwiftCredential
    let oauth: OAuth2Swift
    
    
    /// - Parameters:
    ///   - credentials: Содержит текущие access_token и refresh_token
    ///   - oauth: Нужен для повторной авторизации или для обновления токена
    init(credentials: OAuthSwiftCredential, oauth: OAuth2Swift) {
        self.credentials = credentials
        self.oauth = oauth
        super.init()
    }
    
    /// Добавить в запрос токен авторизации
    func authorizeRequest(_ request: NSMutableURLRequest?, delegate: Any, didFinish sel: Selector) {
        guard
            let instance = delegate as? NSObject,
            let request = request
        else { return }
        
        // блок который добавляет токен в заголовки запроса и уведомляет делегата
        let continuation = { [credentials] (error: Error?) in
            request.allHTTPHeaderFields?[Constant.AuthorizationHeader] = "Bearer \(credentials.oauthToken)"
            
            // Чтобы возвратить обновленный request в вызывающий код (GTMSessionFetcher)
            // мы должны вызвать Obj-C метод по слектору.
            //
            // - (void)authorizer:(id<GTMFetcherAuthorizationProtocol>)auth
            //            request:(NSMutableURLRequest *)authorizedRequest
            //  finishedWithError:(NSError *)error {
            let methodIMP = instance.method(for: sel)
            let method = unsafeBitCast(methodIMP, to: (@convention(c)(Any?,Selector,Any?,Any?,Any?) -> Void).self)
            method(instance, sel, self, request, error)
        }
        
        // Проверяем валидность текущего токена
        if credentials.isTokenExpired() {
            updateToken { error in
                continuation(error)
            }
        } else {
            continuation(nil)
        }
    }
    
    /// Метод проверяет, содержится ли в данном запросе токен авторизации
    func isAuthorizedRequest(_ request: URLRequest) -> Bool {
        if credentials.isTokenExpired() {
            return false
        }
        return request.allHTTPHeaderFields?[Constant.AuthorizationHeader] != nil
    }
    
    
    // MARK: - Эти методы ничего не делают.
    func stopAuthorization() { }
    
    /// Отменить процесс авторизации
    func stopAuthorization(for request: URLRequest) { }
    
    func isAuthorizingRequest(_ request: URLRequest) -> Bool {
        return false
    }
    
    var userEmail: String? {
        return nil
    }
    
    
    // MARK: - Private
    
    private func updateToken(completion: @escaping (Error?) -> Void) {
        oauth.renewAccessToken(
        withRefreshToken: credentials.oauthRefreshToken) { [unowned self] result in
            switch result {
            case .success(let success):
                self.credentials = success.credential
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
