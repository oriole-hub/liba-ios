//
//  UserServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var userService: any UserServiceProtocol {
        get { self[UserServiceKey.self] }
        set { self[UserServiceKey.self] = newValue }
    }
    
    enum UserServiceKey: DependencyKey {
        public static let liveValue: UserServiceProtocol = UserServiceImpl(
            requestService: RequestService<PWNetworkTarget.UserTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum UserTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case getMe
        case updateMe(parameters: User.Parameters.UserUpdate)
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .getMe: "/users/me"
            case .updateMe: "/users/me"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .getMe: .get
            case .updateMe: .put
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .getMe:
                return .requestPlain
            case .updateMe(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            }
        }
        
        public var needsAuth: Bool {
            true
        }
    }
}

// MARK: - Real service

public final class UserServiceImpl: UserServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.UserTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.UserTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func getMe() async throws -> User.Responses.UserResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getMe)
            .map(User.Responses.UserResponse.self, using: decoder)
        
        return response
    }
    
    public func updateMe(parameters: User.Parameters.UserUpdate) async throws -> User.Responses.UserResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.updateMe(parameters: parameters))
            .map(User.Responses.UserResponse.self, using: decoder)
        
        return response
    }
}

