//
//  LoanServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var loanService: any LoanServiceProtocol {
        get { self[LoanServiceKey.self] }
        set { self[LoanServiceKey.self] = newValue }
    }
    
    enum LoanServiceKey: DependencyKey {
        public static let liveValue: LoanServiceProtocol = LoanServiceImpl(
            requestService: RequestService<PWNetworkTarget.LoanTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum LoanTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case reserveBook(parameters: Loan.Parameters.LoanReserveRequest)
        case issueLoan(loanId: UUID)
        case returnLoan(loanId: UUID)
        case getMyLoans(includeReturned: Bool?)
        case getAllLoans
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .reserveBook: "/loans/reserve"
            case .issueLoan(let loanId): "/loans/\(loanId.uuidString)/issue"
            case .returnLoan(let loanId): "/loans/\(loanId.uuidString)/return"
            case .getMyLoans: "/loans/my"
            case .getAllLoans: "/loans/all"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .reserveBook: .post
            case .issueLoan: .post
            case .returnLoan: .post
            case .getMyLoans: .get
            case .getAllLoans: .get
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .reserveBook(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .issueLoan:
                return .requestPlain
            case .returnLoan:
                return .requestPlain
            case .getMyLoans(let includeReturned):
                var parameters: [String: Any] = [:]
                if let includeReturned = includeReturned {
                    parameters["include_returned"] = includeReturned
                }
                return .requestParameters(
                    parameters: parameters,
                    encoding: URLEncoding.queryString
                )
            case .getAllLoans:
                return .requestPlain
            }
        }
        
        public var needsAuth: Bool {
            switch self {
            case .reserveBook: true
            case .issueLoan: true
            case .returnLoan: true
            case .getMyLoans: true
            case .getAllLoans: true
            }
        }
    }
}

// MARK: - Real service

public final class LoanServiceImpl: LoanServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.LoanTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.LoanTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func reserveBook(parameters: Loan.Parameters.LoanReserveRequest) async throws -> Loan.Responses.LoanResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.reserveBook(parameters: parameters))
            .map(Loan.Responses.LoanResponse.self, using: decoder)
        
        return response
    }
    
    public func issueLoan(loanId: UUID) async throws -> Loan.Responses.LoanDetailResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.issueLoan(loanId: loanId))
            .map(Loan.Responses.LoanDetailResponse.self, using: decoder)
        
        return response
    }
    
    public func returnLoan(loanId: UUID) async throws -> Loan.Responses.LoanDetailResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.returnLoan(loanId: loanId))
            .map(Loan.Responses.LoanDetailResponse.self, using: decoder)
        
        return response
    }
    
    public func getMyLoans(includeReturned: Bool?) async throws -> [Loan.Responses.LoanDetailResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getMyLoans(includeReturned: includeReturned))
            .map([Loan.Responses.LoanDetailResponse].self, using: decoder)
        
        return response
    }
    
    public func getAllLoans() async throws -> [Loan.Responses.LoanDetailResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getAllLoans)
            .map([Loan.Responses.LoanDetailResponse].self, using: decoder)
        
        return response
    }
}


