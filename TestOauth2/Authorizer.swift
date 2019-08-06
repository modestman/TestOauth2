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

final class Authorizer: NSObject, GTMFetcherAuthorizationProtocol {
    
    struct Constant {
        static let AuthorizationHeader = "Authorization"
    }
    
    private(set) var credentials: OAuthSwiftCredential
    let oauth: OAuth2Swift
    
    init(credentials: OAuthSwiftCredential, oauth: OAuth2Swift) {
        self.credentials = credentials
        self.oauth = oauth
        super.init()
    }
    
    
    func authorizeRequest(_ request: NSMutableURLRequest?, delegate: Any, didFinish sel: Selector) {
        guard
            let instance = delegate as? NSObject,
            let request = request
        else { return }
        
        if credentials.isTokenExpired() {
            
        }
        
        let continuation = { [credentials] (error: Error?) in
            request.allHTTPHeaderFields?[Constant.AuthorizationHeader] = "Bearer \(credentials.oauthToken)"
            
            // We should call Obj-C method
            // - (void)authorizer:(id<GTMFetcherAuthorizationProtocol>)auth
            //            request:(NSMutableURLRequest *)authorizedRequest
            //  finishedWithError:(NSError *)error {
            let methodIMP: IMP! = instance.method(for: sel)
            let method = unsafeBitCast(methodIMP, to: (@convention(c)(Any?,Selector,Any?,Any?,Any?) -> Void).self)
            method(instance, sel, self, request, nil)
        }
        
        updateToken { error in
            continuation(error)
        }
        
    }
    
    func stopAuthorization() {
        
    }
    
    /// Отменить процесс авторизации
    func stopAuthorization(for request: URLRequest) {
        
    }
    
    func isAuthorizingRequest(_ request: URLRequest) -> Bool {
        return false
    }
    
    /// Метод проверяет, содержатся ли в данном запросе данные авторизации
    func isAuthorizedRequest(_ request: URLRequest) -> Bool {
        if credentials.isTokenExpired() {
            return false
        }
        return request.allHTTPHeaderFields?[Constant.AuthorizationHeader] != nil
    }
    
    var userEmail: String? {
        return nil
    }
    
    
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
