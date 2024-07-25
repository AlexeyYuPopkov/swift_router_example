//
//  FeatureSwiftUIRouter.swift
//  router_example
//
//  Created by Алексей Попков on 25.07.2024.
//

import SwiftUI

final class FeatureSwiftUIRouter: ObservableObject, OnRouteProtocol {
    enum Route {
        case onBack
    }
    
    var onRoute: ((Route) -> Void)?
    
    @Published var path = NavigationPath()
    
    func initialScreen() -> UIViewController {
        return UIHostingController(rootView: InitialView(router: self))
    }
}

extension FeatureSwiftUIRouter {
    struct InitialView: View {
        @StateObject var router: FeatureSwiftUIRouter
        @State var modalView: FeatureSwiftUI.Route?
        
        var body: some View {
            NavigationStack(path: $router.path) {
                FeatureSwiftUI(
                    isModal: true,
                    onRoute: {
                    switch $0 {
                    case .onPushSomthing:
                        router.path.append($0)
                    case .onPresentSomthing:
                        modalView = $0
                    case .onBack:
                        self.router.onRoute?(.onBack)
                    }
                }
                )
                .navigationDestination(for: FeatureSwiftUI.Route.self, destination: showScreen)
                .sheet(item: $modalView, // or .fullScreenCover
                       onDismiss: { modalView = nil },
                       content: showScreen)
            }
        }
    }
}

// MARK: - FeatureSwiftUI.Route
extension FeatureSwiftUIRouter.InitialView {
    @ViewBuilder func showScreen(_ route: FeatureSwiftUI.Route) -> some View {
        switch route {
        case .onPushSomthing:
            AnotherFeatureSwiftUI()
        case .onPresentSomthing:
            AnotherFeatureSwiftUI()
        case .onBack:
            fatalError("Impossible case")
        }
    }
}


