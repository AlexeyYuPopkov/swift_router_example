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
        return vc
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
    private func pushFeatureSwiftUI(_ sender: UIViewController) {
        let vc = UIHostingController(rootView: PushFeatureSwiftUIInitialView(sender: sender))
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    struct PushFeatureSwiftUIInitialView: View {
        let sender: UIViewController
        
        @State var modalView: FeatureSwiftUI.Route?
        
        var body: some View {
                FeatureSwiftUI(
                    isModal: false,
                    onRoute: {
                    switch $0 {
                    case .onPushSomthing:
                        pushPushSomthingScreen()
                        break
                    case .onPresentSomthing:
                        modalView = $0
                    case .onBack:
                        break
                    }
                }
                )
                .sheet(item: $modalView, // or .fullScreenCover
                       onDismiss: { modalView = nil },
                       content: showScreen)
        }
        
        func pushPushSomthingScreen() {
            let vc = UIHostingController(rootView: AnotherFeatureSwiftUI())
            sender.navigationController?.pushViewController(vc, animated: true)
        }
        
        @ViewBuilder func showScreen(_ route: FeatureSwiftUI.Route) -> some View {
            switch route {
            case .onPresentSomthing:
                AnotherFeatureSwiftUI()
            case .onPushSomthing, .onBack:
                fatalError("Impossible case")
            }
        }
    }
}

extension HomeRouter {
    enum Route {
        case onBack(UIViewController)
    }
}
