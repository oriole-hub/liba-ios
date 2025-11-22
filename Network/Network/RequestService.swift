//
//  RequestService.swift
//  RequestKit
//
//  Created by aristarh on 11.11.2025.
//

import Foundation
import Moya
import Alamofire
import KeychainAccess

public final class RequestService<Target: TargetType>: MoyaProvider<Target> {
    
    public init(
        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        trackInflights: Bool = false,
        authOn: Bool = true
    ) {
        let authInterceptor = AuthenticationInterceptor(
            authenticator: JWTAuthenticator(),
            credential: JWTCredential(token: Keychain.app.accessToken)
        )
        let session = Session(
            configuration: .default,
            interceptor: authInterceptor
        )
        super.init(
            endpointClosure: endpointClosure,
            requestClosure: MoyaProvider<Target>.defaultRequestMapping,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session,
            plugins: [
                NetworkLoggerPlugin(),
                NetworkActivityPlugin(networkActivityClosure: { _, _ in }),
            ],
            trackInflights: trackInflights
        )
    }
    
    /// Async/await wrapper for MoyaProvider's request method
    @discardableResult
    func asyncRequest(_ endpoint: Target, progress: ProgressBlock? = nil) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            request(endpoint, progress: progress) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
