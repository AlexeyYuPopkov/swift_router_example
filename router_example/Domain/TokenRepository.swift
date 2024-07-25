//
//  TokenDataSource.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

protocol TokenRepository {
    func getToken() -> TokenProtocol
    func setToken(token: TokenProtocol)
    func dropToken()
}
