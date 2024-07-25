//
//  Dependencies.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import Foundation

/// This class was created for simplification.
/// Actually, the best option for large progects is to use some library for dependency ingection.
/// Also it is good idea to drop dependencies from authorized zone when logout
///
protocol Dependencies {
    func getAuthStatusProviderUsecase() -> AuthStatusProviderUsecase
    
    func getLoginUsecase() -> LoginUsecase
    
    func getLogoutUsecase() -> LogoutUsecase
}

final class DependenciesImpl {
    private lazy var tokenRepository = TokenRepositoryImpl()
    private lazy var authRepository = AuthRepositoryImpl()
    
    private lazy var authStatusProviderUsecase = AuthStatusProviderUsecase(repository: tokenRepository)
    
    private lazy var loginUsecase = LoginUsecase(authRepository: authRepository,
                                                 tokenRepository: tokenRepository)
}

// MARK: - Public
extension DependenciesImpl: Dependencies {
    func getAuthStatusProviderUsecase() -> AuthStatusProviderUsecase {
        return authStatusProviderUsecase
    }
    
    func getLoginUsecase() -> LoginUsecase {
        return loginUsecase
    }
    
    func getLogoutUsecase() -> LogoutUsecase {
        return LogoutUsecase(tokenRepository: tokenRepository)
    }
}
