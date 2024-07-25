//
//  LoginRouter.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import UIKit

final class LoginRouter {
    weak var window: UIWindow!
    
    let dependencies: Dependencies = DependenciesImpl()

    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - Public

extension LoginRouter {
    func initialScreen() -> UIViewController {
        let vc = createInitialVC()
        return UINavigationController(rootViewController: vc)
    }
}

// MARK: - Private, Creating ViewControllers

extension LoginRouter {
    private func createInitialVC() -> UIViewController {
        let authStatus = dependencies.getAuthStatusProviderUsecase().execute()
 
        switch authStatus {
            case .unauthorized:
                return createUnauthZoneInitialVC()
            case .authorized:
                return createAuthZoneInitialVC()
        }
    }
    
    private func createUnauthZoneInitialVC() -> UIViewController {
        let vc = LoginVC(loginUsecase: dependencies.getLoginUsecase())

        vc.onRoute = {
            switch $0 {
                case .onAuth(let sender):
                    self.onPerformeToZoneTransistion(sender)
            case .onFeature(let sender):
                self.showFeatureScreen(sender, parameter: 1)
            }
        }

        return vc
    }

    private func createAuthZoneInitialVC() -> UIViewController {
        let router = HomeRouter(dependencies: dependencies, onRoute: {
            switch $0 {
            case .onBack(let sender):
                self.onPerformeToZoneTransistion(sender)
            }
        })
        
        return router.initialScreen()
    }
}

// MARK: - Show Feature Screen
extension LoginRouter {
    func showFeatureScreen(_ sender: UIViewController, parameter: Int) {
        let vc = UnauthZoneFeatureVC(parameter: parameter)
        vc.onRoute = {
            switch $0 {
            case .onNext(let sender, parameter: let parameter):
                self.showFeatureScreen(sender, parameter: parameter)
            }
        }
        sender.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Private, ViewControllers Transistions

extension LoginRouter {
    private func onPerformeToZoneTransistion(_ sender: UIViewController) {
        let authStatus = dependencies.getAuthStatusProviderUsecase().execute()

        switch authStatus {
            case .unauthorized:
                onUnauthZone(sender)
            case .authorized:
                onAuthZone(sender)
        }
    }

    private func onAuthZone(_ sender: UIViewController) {
        let vc = createAuthZoneInitialVC()
        let nc = UINavigationController(rootViewController: vc)
        transitionProcess(vc: nc)
    }

    private func onUnauthZone(_ sender: UIViewController) {
        let vc = createUnauthZoneInitialVC()
        let nc = UINavigationController(rootViewController: vc)
        transitionProcess(vc: nc)
    }
}

// MARK: - Transition

extension LoginRouter {
    static let transitionDuration: TimeInterval = 0.35

    private func transitionProcess(vc: UIViewController) {
        window.rootViewController = vc
        UIView.transition(
            with: window,
            duration: Self.transitionDuration,
            options: [.transitionCrossDissolve, .allowAnimatedContent, .layoutSubviews],
            animations: nil,
            completion: nil
        )
    }
}
