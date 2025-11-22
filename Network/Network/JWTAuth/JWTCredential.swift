//
//  JWTCredential.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Alamofire

// MARK: - JWTCredential

struct JWTCredential: AuthenticationCredential {
    
    let token: Token?
    
    var requiresRefresh: Bool {
        guard token?.value != nil, let expiration = token?.expiration else { return false }
        return expiration <= Date.now + 58 * 60
    }
}
