//
//  HomeVM.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import Foundation
import Combine

final class HomeVM {
   private let logoutUsecase: LogoutUsecase
    
    let stateSignal = CurrentValueSubject<State, Never>(State.createInitial())
    
    init(logoutUsecase: LogoutUsecase) {
        self.logoutUsecase = logoutUsecase
    }
}

// MARK: - Public
extension HomeVM {
    func logout() {
        var newState = stateSignal.value
        newState.status = .loading
        stateSignal.send(newState)
        Task {
            await logoutUsecase.execute()
            var newState = self.stateSignal.value
            newState.status = .didLogout
            self.stateSignal.send(newState)
        }
    }
}

// MARK: - State

extension HomeVM {
    struct State {
        var status: Status
        var data: Data
        
        static func createInitial() -> State {
            return .init(status: .common, data: Data())
        }
    }
    
    struct Data: Equatable, Hashable {}
    
    enum Status: Equatable, Identifiable {
        static func == (lhs: HomeVM.Status, rhs: HomeVM.Status) -> Bool {
            return lhs.id == rhs.id
        }
        
        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            case .error(_), .common, .didLogout:
                return false
            }
        }
        
        case loading
        case error(Error)
        case common
        case didLogout
        
        var id: String {
            switch self {
            case .loading:
                return "loading"
            case .error(_):
                return "error"
            case .common:
                return "common"
            case .didLogout:
                return "didLogout"
            }
        }
    }
}

// MARK: - State: Equatable, Hashable
extension HomeVM.State: Equatable, Hashable {
    static func == (lhs: HomeVM.State, rhs: HomeVM.State) -> Bool {
        // Assume equal if hash values ​​are equal
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self.status))
        hasher.combine(data)
    }
}

