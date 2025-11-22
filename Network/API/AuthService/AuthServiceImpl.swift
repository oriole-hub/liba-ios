//
//  AuthService.swift
//  RequestKit
//
//  Created by aristarh on 13.11.2025.
//

import Foundation
import Moya
import Dependencies
import KeychainAccess
import Combine

// MARK: - Response Extension for Snake Case Decoding

extension Response {
    func map<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder) throws -> T {
        return try map(type, atKeyPath: nil, using: decoder, failsOnEmptyData: true)
    }
}

// MARK: - Encodable Extension for Snake Case Encoding

extension Encodable {
    func encoded(using encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

// MARK: - Dependencies

extension DependencyValues {
    
    var authService: any AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
    
    enum AuthServiceKey: DependencyKey {
        public static let liveValue: AuthServiceProtocol = AuthServiceImpl(
            requestService: RequestService<PWNetworkTarget.AuthTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum AuthTarget: TargetType {
        
        // MARK: Endpoints
        
        case login(parameters: Auth.Parameters.UserLogin)
        case register(parameters: Auth.Parameters.UserCreate)
        case loginToken(parameters: Auth.Parameters.BodyLogintoken)
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .login: "/auth/login"
            case .register: "/auth/register"
            case .loginToken: "/auth/token"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .login: .post
            case .register: .post
            case .loginToken: .post
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .login(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    // В случае ошибки кодирования возвращаем пустые данные
                    // Это не должно происходить для валидных Codable структур
                    return .requestData(Data())
                }
            case .register(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .loginToken(let parameters):
                return .requestParameters(
                    parameters: [
                        "grant_type": parameters.grantType ?? "password",
                        "username": parameters.username,
                        "password": parameters.password,
                        "scope": parameters.scope ?? "",
                        "client_id": parameters.clientId ?? "",
                        "client_secret": parameters.clientSecret ?? ""
                    ],
                    encoding: URLEncoding.httpBody
                )
            }
        }
    }
}

// MARK: - Real service

public final class AuthServiceImpl: AuthServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.AuthTarget>
    private let userLoggedInSubject = PassthroughSubject<Bool, Never>()
    
    public var userLoggedInPublisher: AnyPublisher<Bool, Never> {
        userLoggedInSubject.eraseToAnyPublisher()
    }
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.AuthTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func login(parameters: Auth.Parameters.UserLogin) async throws -> Auth.Responses.TokenResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.login(parameters: parameters))
            .map(Auth.Responses.TokenResponse.self, using: decoder)

        saveAuthToken(from: response)
        userLoggedInSubject.send(true)
        
        return response
    }
    
    public func register(parameters: Auth.Parameters.UserCreate) async throws -> Auth.Responses.RegisterResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.register(parameters: parameters))
            .map(Auth.Responses.RegisterResponse.self, using: decoder)
        
        return response
    }
    
    public func loginToken(parameters: Auth.Parameters.BodyLogintoken) async throws -> Auth.Responses.TokenResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.loginToken(parameters: parameters))
            .map(Auth.Responses.TokenResponse.self, using: decoder)
        
        saveAuthToken(from: response)
        userLoggedInSubject.send(true)
        
        return response
    }
    
    public func logout() async throws {
        Keychain.app.accessToken = nil
        Keychain.app.refreshToken = nil
        userLoggedInSubject.send(false)
    }
    
    // MARK: Private methods
    
    private func saveAuthToken(from response: Auth.Responses.TokenResponse) {
        // Создаем Token из accessToken с expiration в далеком будущем
        // так как в новом API нет информации о сроке действия токена
        let expiration = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date.distantFuture
        let token = Token(value: response.accessToken, expiration: expiration)
        Keychain.app.accessToken = token
        // В новом API нет refreshToken, оставляем nil или удаляем
        Keychain.app.refreshToken = nil
    }
}
