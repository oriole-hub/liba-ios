//
//  WalletServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var walletService: any WalletServiceProtocol {
        get { self[WalletServiceKey.self] }
        set { self[WalletServiceKey.self] = newValue }
    }
    
    enum WalletServiceKey: DependencyKey {
        public static let liveValue: WalletServiceProtocol = WalletServiceImpl(
            requestService: RequestService<PWNetworkTarget.WalletTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum WalletTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case createMembership(parameters: Wallet.Parameters.WalletMembershipCreate)
        case getMyMembership
        case updateMyMembership(parameters: Wallet.Parameters.WalletMembershipUpdate)
        case deleteMyMembership
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .createMembership: "/wallet"
            case .getMyMembership: "/wallet/me"
            case .updateMyMembership: "/wallet/me"
            case .deleteMyMembership: "/wallet/me"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .createMembership: .post
            case .getMyMembership: .get
            case .updateMyMembership: .put
            case .deleteMyMembership: .delete
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .createMembership(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .getMyMembership:
                return .requestPlain
            case .updateMyMembership(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .deleteMyMembership:
                return .requestPlain
            }
        }
        
        public var needsAuth: Bool {
            true
        }
    }
}

// MARK: - Real service

public final class WalletServiceImpl: WalletServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.WalletTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.WalletTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func createMembership(parameters: Wallet.Parameters.WalletMembershipCreate) async throws -> Wallet.Responses.WalletMembershipResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.createMembership(parameters: parameters))
            .map(Wallet.Responses.WalletMembershipResponse.self, using: decoder)
        
        return response
    }
    
    public func getMyMembership() async throws -> Wallet.Responses.WalletMembershipResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getMyMembership)
            .map(Wallet.Responses.WalletMembershipResponse.self, using: decoder)
        
        return response
    }
    
    public func updateMyMembership(parameters: Wallet.Parameters.WalletMembershipUpdate) async throws -> Wallet.Responses.WalletMembershipResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.updateMyMembership(parameters: parameters))
            .map(Wallet.Responses.WalletMembershipResponse.self, using: decoder)
        
        return response
    }
    
    public func deleteMyMembership() async throws {
        _ = try await requestService
            .asyncRequest(.deleteMyMembership)
    }
}

