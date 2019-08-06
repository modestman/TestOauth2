//
//  OIDTokenUtilities.swift
//  TestOauth2
//
//  Created by Anton Glezman on 06/08/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation
import CommonCrypto.Random
import CommonCrypto.CommonDigest

struct OIDTokenUtilities {
    
    /// Number of random bytes generated for the @ state.
    private static let kStateSizeBytes = 32
    
    /// Number of random bytes generated for the @ codeVerifier.
    private static let kCodeVerifierBytes = 32
    
    
    public static func generateCodeVerifier() -> String? {
        return OIDTokenUtilities.randomURLSafeString(withSize: kCodeVerifierBytes)
    }
    
    public static func generateState() -> String? {
        return OIDTokenUtilities.randomURLSafeString(withSize: kStateSizeBytes)
    }
    
    public static func codeChallengeS256(forVerifier codeVerifier: String?) -> String? {
        guard let data = codeVerifier?.data(using: .utf8) else { return nil }
        // generates the code_challenge per spec https://tools.ietf.org/html/rfc7636#section-4.2
        // code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
        // NB. the ASCII conversion on the code_verifier entropy was done at time of generation.
        let sha256Verifier = OIDTokenUtilities.sha256(data)
        return OIDTokenUtilities.encodeBase64urlNoPadding(sha256Verifier)
    }
    
    public static func encodeBase64urlNoPadding(_ data: Data?) -> String? {
        var base64string = data?.base64EncodedString(options: [])
        // converts base64 to base64url
        base64string = base64string?.replacingOccurrences(of: "+", with: "-")
        base64string = base64string?.replacingOccurrences(of: "/", with: "_")
        // strips padding
        base64string = base64string?.replacingOccurrences(of: "=", with: "")
        return base64string
    }
    
    public static func randomURLSafeString(withSize size: Int) -> String?  {
        var bytes = [Int8](repeating: 0, count: size)
        let status = CCRandomGenerateBytes(&bytes, bytes.count)
        if status != kCCSuccess {
            return nil
        }
        let data = Data(bytes: bytes, count: bytes.count)
        return OIDTokenUtilities.encodeBase64urlNoPadding(data)
    }
    
    /// Computes the SHA256 data digest.
    ///
    /// - Returns: data digest (cryptographic hash) in SHA256.
    public static func sha256(_ data: Data) -> Data {
        var bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> Void in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &bytes)
        }
        return Data(bytes)
    }
}
