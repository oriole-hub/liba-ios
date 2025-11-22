//
//  LoanServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol LoanServiceProtocol {
    
    func reserveBook(parameters: Loan.Parameters.LoanReserveRequest) async throws -> Loan.Responses.LoanResponse
    
    func issueLoan(loanId: UUID) async throws -> Loan.Responses.LoanDetailResponse
    
    func returnLoan(loanId: UUID) async throws -> Loan.Responses.LoanDetailResponse
    
    func getMyLoans(includeReturned: Bool?) async throws -> [Loan.Responses.LoanDetailResponse]
    
    func getAllLoans() async throws -> [Loan.Responses.LoanDetailResponse]
}

