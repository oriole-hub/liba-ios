//
//  TargetType+Helpers.swift
//  RequestKit
//
//  Created by aristarh on 11.11.2025.
//

import Foundation
import Moya

public extension TargetType {
    
    var serverURL: URL {
        let connProtocol = "https://"
        let servURL = "ekb.devoriole.ru"
        let apiURL = "/api"
        return URL(string: connProtocol + servURL + apiURL)!
    }
    
    var headers: [String : String]? {
        defaultHeaders
    }
    
    var defaultHeaders: [String : String]? {
        ["Content-type": "application/json"]
    }
}

public protocol PWTargetType: TargetType {
    
    var needsAuth: Bool { get }
}
