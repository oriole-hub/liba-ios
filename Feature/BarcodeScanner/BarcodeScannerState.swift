//
//  BarcodeScannerState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import SwiftNavigation

final class BarcodeScannerState: ObservableObject {
    
    // MARK: Properties
    
    lazy var screen = BarcodeScannerScreen(state: self)
    
    @Published var scannedISBN: String?
    @Published var isScanning: Bool = false
    @Published var errorMessage: String?
    
    var onScanned: ((String) -> Void)?
    
    // MARK: Init
    
    init(onScanned: ((String) -> Void)? = nil) {
        self.onScanned = onScanned
    }
    
    // MARK: Actions
    
    func handleScannedBarcode(_ barcode: String) {
        let isbn = extractISBN(from: barcode)
        scannedISBN = isbn
        if let isbn = isbn {
            onScanned?(isbn)
        }
    }
    
    // MARK: Private methods
    
    private func extractISBN(from barcode: String) -> String? {
        // EAN-13 и UPC поддерживаются
        // EAN-13 имеет 13 цифр, UPC-A имеет 12 цифр, UPC-E имеет 8 цифр
        
        let digits = barcode.filter { $0.isNumber }
        
        // UPC-A (12 цифр) - добавляем 0 в начало для конвертации в EAN-13
        if digits.count == 12 {
            let ean13 = "0" + digits
            return convertEAN13ToISBN(ean13) ?? ean13
        }
        
        // EAN-13 (13 цифр)
        if digits.count == 13 {
            return convertEAN13ToISBN(digits) ?? digits
        }
        
        // UPC-E или EAN-8 (8 цифр) - не поддерживаем прямое преобразование, используем как есть
        if digits.count == 8 {
            return digits
        }
        
        // Для остальных случаев возвращаем как есть
        return barcode
    }
    
    private func convertEAN13ToISBN(_ ean13: String) -> String? {
        // ISBN-13 начинается с префиксов 978 или 979
        // EAN-13 для ISBN имеет формат: 978 или 979 + 9 цифр + 1 контрольная цифра EAN
        
        guard ean13.count == 13 else { return nil }
        
        let prefix = String(ean13.prefix(3))
        
        // Если это ISBN (978 или 979), извлекаем ISBN-13
        if prefix == "978" || prefix == "979" {
            // ISBN-13 = 978/979 + 9 цифр ISBN + контрольная цифра ISBN
            // EAN-13 = 978/979 + 9 цифр ISBN + контрольная цифра EAN
            // Нужно пересчитать контрольную цифру для ISBN
            
            let isbnWithoutCheck = String(ean13.prefix(12))
            let isbnCheckDigit = calculateISBN13CheckDigit(isbnWithoutCheck)
            return isbnWithoutCheck + String(isbnCheckDigit)
        }
        
        return nil
    }
    
    private func calculateISBN13CheckDigit(_ isbn: String) -> Int {
        // ISBN-13 контрольная цифра рассчитывается по алгоритму Luhn
        guard isbn.count == 12 else { return 0 }
        
        var sum = 0
        for (index, char) in isbn.enumerated() {
            guard let digit = Int(String(char)) else { return 0 }
            let multiplier = (index % 2 == 0) ? 1 : 3
            sum += digit * multiplier
        }
        
        let remainder = sum % 10
        return remainder == 0 ? 0 : 10 - remainder
    }
}

