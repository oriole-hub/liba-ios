//
//  JWTAuthenticationActor.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//


// MARK: - JWTAuthenticationActor

actor JWTAuthenticationActor {
    
    private var isRefreshing = false
    private var refreshCompletions: [(Result<JWTCredential, Error>) -> Void] = []
    
    /// Атомарная операция: добавить completion и вернуть был ли уже запущен refresh
    /// Гарантирует что только первый запрос начнёт refresh, остальные будут ждать
    func addCompletionAndCheckIfRefreshing(_ completion: @escaping (Result<JWTCredential, Error>) -> Void) -> Bool {
        refreshCompletions.append(completion)
        
        if isRefreshing {
            // ✅ Кто-то уже обновляет токен, просто ждём
            return true
        } else {
            // ✅ Мы первые, начинаем обновление
            isRefreshing = true
            return false
        }
    }
    
    /// Атомарная операция: сбросить флаг и получить все completions
    func completeRefreshAndGetCompletions() -> [(Result<JWTCredential, Error>) -> Void] {
        isRefreshing = false
        let completions = refreshCompletions
        refreshCompletions.removeAll()
        return completions
    }
}
