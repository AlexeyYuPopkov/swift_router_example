//
//  LogoutUsecase.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

final class LogoutUsecase {
  private let tokenRepository: TokenRepository

    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func execute() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        tokenRepository.dropToken()
    }
}
