//
//  Param.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//


import Foundation

public extension DateFormatter {
    static var iso8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

public extension JSONDecoder {
    static let `default`: JSONDecoder = JSONDecoder
        .with(.roundedDate(.millisecondsAndSeconds))
}

public extension JSONEncoder {
    static let `default`: JSONEncoder = JSONEncoder
        .with(.roundedDate(.millisecondsAndSeconds))
}

public extension JSONDecoder {
    enum Param {
        case roundedDate(Date.RoundingPrecision)
        case snakeCase
        case custom((JSONDecoder) -> Void)
        
        func apply(decoder: JSONDecoder) -> Void {
            switch self {
            case .roundedDate(let precision):
                decoder.withRoundedDate(precision)
            case .snakeCase:
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            case .custom(let functor):
                functor(decoder)
            }
        }
    }
}
    
public extension JSONDecoder {
    static func with(_ params: Param...) -> JSONDecoder {
        params.reduce(into: JSONDecoder()) { $1.apply(decoder: $0) }
    }
    
    func withRoundedDate(_ precision: Date.RoundingPrecision) -> Void {
        dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            var dateString = try container.decode(String.self)
            
            // Попробуем сначала парсить с timezone (стандартный ISO8601)
            if let date = DateFormatter.iso8601.date(from: dateString) {
                return date.rounded(precision)
            }
            
            // Если строка заканчивается на 'Z', заменяем на +0000 для ISO8601DateFormatter
            if dateString.hasSuffix("Z") {
                let withoutZ = String(dateString.dropLast())
                if let date = DateFormatter.iso8601.date(from: withoutZ + "+0000") {
                    return date.rounded(precision)
                }
            }
            
            // Пробуем разные форматы с 'Z' в конце и разным количеством дробных секунд
            let formatsWithZ = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",  // 6 цифр (микросекунды) с Z
                "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'",   // 5 цифр с Z
                "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'",    // 4 цифры с Z
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",     // 3 цифры (миллисекунды) с Z
                "yyyy-MM-dd'T'HH:mm:ss.SS'Z'",      // 2 цифры с Z
                "yyyy-MM-dd'T'HH:mm:ss.S'Z'",       // 1 цифра с Z
                "yyyy-MM-dd'T'HH:mm:ss'Z'"          // без дробных секунд с Z
            ]
            
            for format in formatsWithZ {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
                
                if let date = formatter.date(from: dateString) {
                    return date.rounded(precision)
                }
            }
            
            // Пробуем разные форматы без timezone с разным количеством дробных секунд
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",  // 6 цифр (микросекунды)
                "yyyy-MM-dd'T'HH:mm:ss.SSSSS",   // 5 цифр
                "yyyy-MM-dd'T'HH:mm:ss.SSSS",    // 4 цифры
                "yyyy-MM-dd'T'HH:mm:ss.SSS",     // 3 цифры (миллисекунды)
                "yyyy-MM-dd'T'HH:mm:ss.SS",      // 2 цифры
                "yyyy-MM-dd'T'HH:mm:ss.S",       // 1 цифра
                "yyyy-MM-dd'T'HH:mm:ss"          // без дробных секунд
            ]
            
            for format in formats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
                
                if let date = formatter.date(from: dateString) {
                    return date.rounded(precision)
                }
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date format: \(dateString)"
            )
        }
    }
}

public extension JSONEncoder {
    enum Param {
        case roundedDate(Date.RoundingPrecision)
        case snakeCase
        case custom((JSONEncoder) -> Void)
        
        func apply(encoder: JSONEncoder) -> Void {
            switch self {
            case .roundedDate(let precision):
                encoder.withRoundedDate(precision)
            case .snakeCase:
                encoder.keyEncodingStrategy = .convertToSnakeCase
            case .custom(let functor):
                functor(encoder)
            }
        }
    }
}
    
public extension JSONEncoder {
    static func with(_ params: Param...) -> JSONEncoder {
        params.reduce(into: JSONEncoder()) { $1.apply(encoder: $0) }
    }
    
    func withRoundedDate(_ precision: Date.RoundingPrecision) -> Void {
        dateEncodingStrategy = .custom { date, encoder in
            let formattedDate = date.rounded(precision)
            
            let dateString = DateFormatter.iso8601.string(from: formattedDate)
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        }
    }
}
