//
//  Keychain+Extensions.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//


import Foundation
import KeychainAccess
import UIKit

// MARK: - UserDefaults

public extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.com.oriole-books")!
    
    var userBarcode: String? {
        get { string(forKey: "user_barcode") }
        set { set(newValue, forKey: "user_barcode") }
    }
    
    var userFullName: String? {
        get { string(forKey: "user_full_name") }
        set { set(newValue, forKey: "user_full_name") }
    }
}

// MARK: - Keychain

public extension Keychain {
    
    static let app = Keychain()
//    Keychain(
//        server: "https://oriole-books.com",
//        protocolType: .https,
//        accessGroup: "R9V39TQV89.com.oriole-books"
//    )
    
    var accessToken: Token? {
        get {
            guard let data = try? getData("access_jwt") else { return nil }
            return try? JSONDecoder().decode(Token.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                try? label("AccessToken").set(data, key: "access_jwt")
            } else {
                try? label("AccessToken").remove("access_jwt")
            }
        }
    }
    
    var refreshToken: Token? {
        get {
            guard let data = try? getData("refresh_jwt") else { return nil }
            return try? JSONDecoder().decode(Token.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                try? label("RefreshToken").set(data, key: "refresh_jwt")
            } else {
                try? label("RefreshToken").remove("refresh_jwt")
            }
        }
    }
    
    var deviceId: String {
        get {
            guard let deviceId = try? getString("device_id") else {
                return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            }
            return deviceId
        }
        set {
            try? label("DeviceId").set(newValue, key: "device_id")
        }
    }
}
