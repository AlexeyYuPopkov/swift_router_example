//
//  LoginUsecase.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

final class LoginUsecase {
    private let authRepository: AuthRepository
    private let tokenRepository: TokenRepository

    init(
        authRepository: AuthRepository,
        tokenRepository: TokenRepository
    ) {
        self.authRepository = authRepository
        self.tokenRepository = tokenRepository
    }
    
    func execute(
        login: String,
        password: String,
        completion: @escaping (Result<any TokenProtocol, Error>) -> Void
    ) {
        authRepository.tryAuthorise(
            login: login,
            password: password
        ) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let token):
                    self.tokenRepository.setToken(token: token)
                    completion(.success(token))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
