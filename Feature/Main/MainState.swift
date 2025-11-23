//
//  MainState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation
import PassKit
import KeychainAccess

final class MainState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.bookService) private var bookService
    @Dependency(\.userService) private var userService
    @Dependency(\.walletService) private var walletService
    
    @Published var searchText: String = "" {
        didSet {
            // Debounce поиска - отменяем предыдущую задачу и создаем новую
            searchTask?.cancel()
            searchTask = Task {
                // Ждем 500ms перед выполнением поиска
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
                guard !Task.isCancelled else { return }
                await performSearch()
            }
        }
    }
    @Published var books: [Book.Responses.BookDetailResponse] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var userFullName: String = "ФАМИЛИЯ И.О."
    @Published var isCardFlipped: Bool = false
    @Published var walletPass: PKPass?
    
    private var currentSkip: Int = 0
    private let limit: Int = 20
    @Published var hasMoreBooks: Bool = true
    private var searchTask: Task<Void, Never>?
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case book(BookState)
    }
    
    @Published var destination: Destination?
    @Published var showBarcodeScanner: Bool = false
    @Published var showAddToWallet: Bool = false
 
    lazy var screen = MainScreen(state: self)
    
    // MARK: Init
    
    init() {
        // Загружаем сохраненное имя при инициализации
        if let savedName = UserDefaults.group.userFullName {
            userFullName = savedName.uppercased()
        }
    }
    
    // MARK: Actions
    
    @MainActor
    func loadBooks() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentSkip = 0
        
        do {
            let loadedBooks: [Book.Responses.BookDetailResponse]
            
            // Если есть поисковый запрос, используем поиск, иначе загружаем все книги
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let searchParameters = Book.Parameters.BookSearchRequest(query: searchText)
                loadedBooks = try await bookService.searchBooks(
                    parameters: searchParameters,
                    skip: 0,
                    limit: limit
                )
            } else {
                loadedBooks = try await bookService.getAllBooks(skip: 0, limit: limit)
            }
            
            books = loadedBooks
            currentSkip = loadedBooks.count
            hasMoreBooks = loadedBooks.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreBooks() async {
        guard !isLoadingMore, !isLoading, hasMoreBooks else { return }
        
        isLoadingMore = true
        
        do {
            let loadedBooks: [Book.Responses.BookDetailResponse]
            
            // Если есть поисковый запрос, используем поиск, иначе загружаем все книги
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let searchParameters = Book.Parameters.BookSearchRequest(query: searchText)
                loadedBooks = try await bookService.searchBooks(
                    parameters: searchParameters,
                    skip: currentSkip,
                    limit: limit
                )
            } else {
                loadedBooks = try await bookService.getAllBooks(skip: currentSkip, limit: limit)
            }
            
            books.append(contentsOf: loadedBooks)
            currentSkip += loadedBooks.count
            hasMoreBooks = loadedBooks.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    @MainActor
    private func performSearch() async {
        // Выполняем поиск только если текст не пустой
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await loadBooks()
        } else {
            // Если поиск очищен, загружаем все книги
            await loadBooks()
        }
    }
    
    @MainActor
    func loadUserData() async {
        do {
            let userResponse = try await userService.getMe()
            UserDefaults.group.userBarcode = userResponse.barcode
            UserDefaults.group.userFullName = userResponse.fullName
            userFullName = userResponse.fullName.uppercased()
            
            // Загружаем PKPass для кошелька
            await loadWalletPass()
        } catch {
            // Не показываем ошибку пользователю, если не удалось загрузить данные
            // Можно логировать ошибку, если нужно
            print("Failed to load user data: \(error.localizedDescription)")
            // Используем сохраненное имя, если загрузка не удалась
            if let savedName = UserDefaults.group.userFullName {
                userFullName = savedName.uppercased()
            }
        }
    }
    
    @MainActor
    func loadWalletPass() async {
        // Получаем данные пользователя для создания membership
        let memberName = userFullName.isEmpty ? (UserDefaults.group.userFullName ?? "ПОЛЬЗОВАТЕЛЬ") : userFullName
        let memberNumber = UserDefaults.group.userBarcode ?? ""
        let barcodeValue = memberNumber
        
        // Сначала пытаемся получить существующий membership
        var membership: Wallet.Responses.WalletMembershipResponse?
        
//        do {
//            membership = try await walletService.getMyMembership()
//        } catch {
        
//            // Если membership не существует, создаем новый
//            print("Membership not found, creating new one: \(error.localizedDescription)")
            
            do {
                let createParameters = Wallet.Parameters.WalletMembershipCreate(
                    memberName: memberName,
                    memberNumber: memberNumber,
                    barcodeLabel: barcodeValue.isEmpty ? nil : barcodeValue,
                    barcodeValue: barcodeValue.isEmpty ? nil : barcodeValue,
                    expiresAt: "2026-12-22T17:49:09Z"
                )
                membership = try await walletService.createMembership(parameters: createParameters)
                print("Membership created successfully")
            } catch {
                print("Failed to create membership: \(error.localizedDescription)")
                walletPass = nil
                return
            }
//        }
        
        // Проверяем наличие URL для загрузки PKPass
        guard let membership = membership,
              let passUrlString = membership.passHrefApple,
              let passUrl = URL(string: passUrlString) else {
            walletPass = nil
            return
        }
        
        // Загружаем .pkpass файл с сервера
        do {
            var request = URLRequest(url: passUrl)
            
            // Добавляем авторизацию, если есть токен
            if let token = Keychain.app.accessToken {
                request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            print("DATA", data)
            print("RESPONSE", response)
            
            // Проверяем успешность ответа
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Failed to load wallet pass: Invalid response")
                walletPass = nil
                return
            }
            
            // Создаем PKPass из загруженных данных
            walletPass = try PKPass(data: data)
        } catch {
            print("Failed to load wallet pass: \(error.localizedDescription)")
            walletPass = nil
        }
    }
}
