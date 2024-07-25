//
//  AuthStatusPrividerUsecase.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

enum AuthStatus {
    case authorized
    case unauthorized
}

final class AuthStatusProviderUsecase {
    private let repository: TokenRepository

    init(repository: TokenRepository) {
        self.repository = repository
    }

    func execute() -> AuthStatus {
        let token = repository.getToken()
        return token.isValid ? .authorized : .unauthorized
    }
}
