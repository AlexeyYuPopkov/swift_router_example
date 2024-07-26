//
//  HomeRouter.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import UIKit
import SwiftUI

final class HomeRouter: OnRouteProtocol {
    var onRoute: ((Route) -> Void)?
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies, onRoute: ((Route) -> Void)?) {
        self.dependencies = dependencies
        self.onRoute = onRoute
    }
}

extension HomeRouter {
    func initialScreen() -> UIViewController {
        let vc = createInitialScreen()
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
}

extension HomeRouter {
    private func createInitialScreen() -> UIViewController {
        let logoutUsecase = dependencies.getLogoutUsecase()
        
        let vm = HomeVM(logoutUsecase: logoutUsecase)
        
        let vc = HomeVC(vm: vm)

        vc.onRoute = {
            switch $0 {
            case .onPresentFeatureSwiftUI(let sender):
                self.presentFeatureSwiftUI(sender)
            case .onPushFeatureSwiftUI(let sender):
                self.pushFeatureSwiftUI(sender)
            case .onLogout(let sender):
                self.onRoute?(.onBack(sender))
            }
        }

        return vc
    }
}

// MARK: - Present SwiftUI Feature
extension HomeRouter {
    private func presentFeatureSwiftUI(_ sender: UIViewController) {
        let router = FeatureSwiftUIRouter()
        
        let vc = router.initialScreen()
        vc.modalPresentationStyle = .fullScreen
        
        router.onRoute = { [weak vc] in
            switch $0 {
            case .onBack:
                vc?.dismiss(animated: true)
            }
        }
        
        sender.present(vc, animated: true)
    }
}

// MARK: - Push SwiftUI Feature
extension HomeRouter {
    
    final class Box {
        weak var vc: UIViewController!
    }
    
    private func pushFeatureSwiftUI(_ sender: UIViewController) {
        let box = Box()
        
        let vc = UIHostingController(rootView:
                                        FeatureSwiftUI(
                                            isModal: false,
                                            onRoute: {
                                                switch $0 {
                                                case .onPushSomthing:
                                                    self.pushPushSomthingScreen(sender: box)
                                                    break
                                                case .onPresentSomthing:
                                                    self.presentPushSomthingScreen(sender: box)
                                                case .onBack:
                                                    break
                                                }
                                            }
                                        )
        )
        
        box.vc = vc
        
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushPushSomthingScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherFeatureSwiftUI())
        sender.vc.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPushSomthingScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherFeatureSwiftUI())
        sender.vc.present(vc, animated: true)
    }
}

extension HomeRouter {
    enum Route {
        case onBack(UIViewController)
    }
}
