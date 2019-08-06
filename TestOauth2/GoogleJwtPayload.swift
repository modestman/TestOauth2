//
//  GoogleJwtPayload.swift
//  TestOauth2
//
//  Created by Anton Glezman on 06/08/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

struct GoogleJwtPayload: Decodable {
    
    /// Issuer
    let iss: String
    
    /// Subject
    let sub: String
    
    /// Audience
    let aud: String
    
    /// Issued at
    let iat: Int
    
    /// Expiration time
    let exp: Int
    
    let email: String?
    
    let name: String?
    
    let givenName: String?
    
    let familyName: String?
    
    let locale: String?
    
    let picture: String?
    
}
