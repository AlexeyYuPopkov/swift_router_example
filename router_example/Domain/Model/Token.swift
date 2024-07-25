//
//  Token.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

protocol TokenProtocol {
    var token: String { get }
    var isValid: Bool { get }
}

struct Token: TokenProtocol {
    let token: String

    var isValid: Bool {
        return !token.isEmpty
    }

    init(token: String) {
        self.token = token
        assert(!token.isEmpty, "invalid token")
    }
}

struct EmptyToken: TokenProtocol {
    let token: String = ""
    let isValid = false
}
