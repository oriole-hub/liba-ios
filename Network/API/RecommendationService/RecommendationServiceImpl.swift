//
//  RecommendationServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var recommendationService: any RecommendationServiceProtocol {
        get { self[RecommendationServiceKey.self] }
        set { self[RecommendationServiceKey.self] = newValue }
    }
    
    enum RecommendationServiceKey: DependencyKey {
        public static let liveValue: RecommendationServiceProtocol = RecommendationServiceImpl(
            requestService: RequestService<PWNetworkTarget.RecommendationTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum RecommendationTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case getRecommendations(skip: Int?, limit: Int?)
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .getRecommendations: "/recommendations"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .getRecommendations: .get
            }
        }
        
        public var task: Moya.Task {
            switch self {
            case .getRecommendations(let skip, let limit):
                var parameters: [String: Any] = [:]
                if let skip = skip {
                    parameters["skip"] = skip
                }
                if let limit = limit {
                    parameters["limit"] = limit
                }
                return .requestParameters(
                    parameters: parameters,
                    encoding: URLEncoding.queryString
                )
            }
        }
        
        public var needsAuth: Bool {
            switch self {
            case .getRecommendations: true
            }
        }
    }
}

// MARK: - Real service

public final class RecommendationServiceImpl: RecommendationServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.RecommendationTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.RecommendationTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func getRecommendations(skip: Int?, limit: Int?) async throws -> [Book.Responses.BookDetailResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getRecommendations(skip: skip, limit: limit))
            .map([Book.Responses.BookDetailResponse].self, using: decoder)
        
        return response
    }
}

