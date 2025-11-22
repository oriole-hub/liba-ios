//
//  JWTAuthenticationActor.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Alamofire
import KeychainAccess

// MARK: - JWTAuthenticator

final class JWTAuthenticator: @unchecked Sendable {
    
    // MARK: Properties
    
    private let authActor = JWTAuthenticationActor()
}

// MARK: - Internal methods

extension JWTAuthenticator: Authenticator {
    
    func apply(_ credential: JWTCredential, to urlRequest: inout URLRequest) {
        guard let token = credential.token?.value else { return }
        urlRequest.headers.add(.authorization(bearerToken: token))
    }
    
    func refresh(_ credential: JWTCredential, for session: Session, completion: @escaping (Result<JWTCredential, Error>) -> Void) {
//        Task {
//            // ✅ Атомарная проверка: добавляем completion и узнаём, нужно ли нам делать refresh
//            let alreadyRefreshing = await authActor.addCompletionAndCheckIfRefreshing(completion)
//            
//            if alreadyRefreshing {
//                // ✅ Кто-то уже обновляет токен, наш completion вызовется автоматически
//                // Просто выходим и ждём результата
//                return
//            }
//            
//            // ✅ Мы первые! Выполняем refresh для всех ожидающих запросов
//            guard let token = Keychain.app.refreshToken else {
//                await handleAuthenticationFailure()
//                return
//            }
//            
//            do {
//                let result = try await performRefresh(with: token, session: session)
//                await completeRefresh(with: .success(result))
//            } catch {
//                await completeRefresh(with: .failure(error))
//            }
//        }
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return error.asAFError?.isUnauthorized ?? false
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: JWTCredential) -> Bool {
        guard let token = credential.token else { return true }
        return urlRequest.headers.contains(.authorization(bearerToken: token.value))
    }
}

// MARK: - Private Methods

private extension JWTAuthenticator {
    
//    func performRefresh(with token: Token, session: Session) async throws -> JWTCredential {
//        let headers = makeHeaders(with: token)
//        let url = URL(string: "https://localhost:3000")!.appendingPathComponent("/auth/refresh")
//        let keychain = Keychain.app
//        let parameters = Auth.Parameters.Refresh(token: keychain.accessToken?.value ?? "")
//   
//        return try await withCheckedThrowingContinuation { continuation in
//            session.request(url, method: .post, parameters: parameters, headers: headers)
//                .validate(statusCode: 200..<300)
//                .responseDecodable(
//                    of: Auth.Responses.Refresh.self,
//                    decoder: JSONDecoder.default
//                ) { [weak self] response in
//                    guard let self = self else {
//                        continuation.resume(throwing: ErrorResponse(error: true, reason: "Self is nil"))
//                        return
//                    }
//                    
//                    switch response.result {
//                    case .success(let value):
////                        switch requesterType {
////                        case .customer:
////                            keychain.accessToken = value.accessToken
////                        case .professional:
////                            keychain.employeeToken = value.accessToken
////                        case .none:
////                            keychain.accessToken = nil
////                            keychain.employeeToken = nil
////                        }
//                        keychain.refreshToken = value.refreshToken
//                        let credential = JWTCredential(token: value.accessToken)
//                        continuation.resume(returning: credential)
//                    case .failure(let error):
//                        if let afError = error.asAFError,
//                           (afError.responseCode == 401 || afError.isUnauthorizedError) {
//                            self.clearAuthenticationState()
//                        }
//                        continuation.resume(throwing: error)
//                    }
//                }
//        }
//    }
    
    func handleAuthenticationFailure() async {
        clearAuthenticationState()
        let error = ErrorResponse(error: true, reason: "No refresh token found")
        await completeRefresh(with: .failure(error))
    }
    
    func completeRefresh(with result: Result<JWTCredential, Error>) async {
        // ✅ Атомарно получаем все completions и сбрасываем флаг
        let completions = await authActor.completeRefreshAndGetCompletions()
        
        // ✅ Вызываем все ожидающие completions с результатом (успех или ошибка)
        completions.forEach { $0(result) }
    }
    
    func clearAuthenticationState() {
        Keychain.app.accessToken = nil
        Keychain.app.refreshToken = nil
    }
    
    func makeHeaders(with token: Token) -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers.deviceId = Keychain.app.deviceId
        headers.add(.authorization(bearerToken: token.value))
        return headers
    }
}

