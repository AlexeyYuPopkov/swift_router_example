//
//  TokenRepositoryImpl.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

// Do not store sensetive data (like tokens) in UserDefaults for real application
final class TokenRepositoryImpl: TokenRepository {
    private enum Key {
        static let tokenKey = "DiStorage_Example.Key.TokenKey"
    }

    func getToken() -> TokenProtocol {
        let preferences = UserDefaults.standard
        if let tokenStr = preferences.string(forKey: Key.tokenKey), !tokenStr.isEmpty {
            return Token(token: tokenStr)
        } else {
            return EmptyToken()
        }
    }

    func setToken(token: TokenProtocol) {
        if let token = token as? Token, token.isValid  {
            let preferences = UserDefaults.standard
            preferences.setValue(token.token, forKey: Key.tokenKey)
        } else {
            dropToken()
        }
    }

    func dropToken() {
        let preferences = UserDefaults.standard
        preferences.setValue("", forKey: Key.tokenKey)
    }
}
