//
//  AuthRepository.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

protocol AuthRepository {
    func tryAuthorise(login: String, password: String, completion: @escaping (Result<any TokenProtocol, Error>) -> Void)
}
