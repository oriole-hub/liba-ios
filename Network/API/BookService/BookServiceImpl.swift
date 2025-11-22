//
//  BookServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var bookService: any BookServiceProtocol {
        get { self[BookServiceKey.self] }
        set { self[BookServiceKey.self] = newValue }
    }
    
    enum BookServiceKey: DependencyKey {
        public static let liveValue: BookServiceProtocol = BookServiceImpl(
            requestService: RequestService<PWNetworkTarget.BookTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum BookTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case createBook(parameters: Book.Parameters.BookCreate)
        case getAllBooks(skip: Int?, limit: Int?)
        case getBookByISBN(isbn: String)
        case addBookInstance(bookId: UUID, parameters: Book.Parameters.BookInstanceCreate)
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .createBook: "/books"
            case .getAllBooks: "/books"
            case .getBookByISBN(let isbn): "/books/isbn/\(isbn)"
            case .addBookInstance(let bookId, _): "/books/\(bookId.uuidString)/instances"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .createBook: .post
            case .getAllBooks: .get
            case .getBookByISBN: .get
            case .addBookInstance: .post
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .createBook(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .getAllBooks(let skip, let limit):
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
            case .getBookByISBN:
                return .requestPlain
            case .addBookInstance(_, let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            }
        }
        
        public var needsAuth: Bool {
            switch self {
            case .createBook: true
            case .getAllBooks: false
            case .getBookByISBN: false
            case .addBookInstance: true
            }
        }
    }
}

// MARK: - Real service

public final class BookServiceImpl: BookServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.BookTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.BookTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func createBook(parameters: Book.Parameters.BookCreate) async throws -> Book.Responses.BookResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.createBook(parameters: parameters))
            .map(Book.Responses.BookResponse.self, using: decoder)
        
        return response
    }
    
    public func getAllBooks(skip: Int?, limit: Int?) async throws -> [Book.Responses.BookDetailResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getAllBooks(skip: skip, limit: limit))
            .map([Book.Responses.BookDetailResponse].self, using: decoder)
        
        return response
    }
    
    public func getBookByISBN(isbn: String) async throws -> Book.Responses.BookDetailResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getBookByISBN(isbn: isbn))
            .map(Book.Responses.BookDetailResponse.self, using: decoder)
        
        return response
    }
    
    public func addBookInstance(bookId: UUID, parameters: Book.Parameters.BookInstanceCreate) async throws -> Book.Responses.BookInstanceResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.addBookInstance(bookId: bookId, parameters: parameters))
            .map(Book.Responses.BookInstanceResponse.self, using: decoder)
        
        return response
    }
}

