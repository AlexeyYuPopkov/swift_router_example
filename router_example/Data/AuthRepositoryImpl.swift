//
//  AuthRepositoryImpl.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    func tryAuthorise(login: String, password: String,  completion: @escaping (Result<any TokenProtocol, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
            completion(.success(Token(token: "\(login)+\(password)")) )
        }
    }
}
