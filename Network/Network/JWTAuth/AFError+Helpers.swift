//
//  AFError+Helpers.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Alamofire

// MARK: - AFError Extensions

extension AFError {
    
    var isUnauthorized: Bool {
        guard case let .responseValidationFailed(reason) = self else { return false }
        
        switch reason {
        case .unacceptableStatusCode(let code):
            return code == 401
        case .customValidationFailed(let error):
            return (error as? ErrorResponse)?.reason == "Unauthorized"
        default:
            return false
        }
    }
    
    var isUnauthorizedError: Bool {
        if case .responseValidationFailed(.customValidationFailed(let error)) = self,
           let errorResponse = error as? ErrorResponse,
           errorResponse.reason == "Unauthorized" {
            return true
        }
        return false
    }
}
