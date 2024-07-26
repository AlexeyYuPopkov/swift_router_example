//
//  SwiftUIRouter.swift
//  router_example
//
//  Created by Алексей Попков on 25.07.2024.
//

import SwiftUI

final class SwiftUIRouter: ObservableObject, OnRouteProtocol {
    enum Route {
        case onBack
    }
    
    var onRoute: ((Route) -> Void)?
    
    @Published var path = NavigationPath()
    
    func initialScreen() -> UIViewController {
        return UIHostingController(rootView: InitialView(router: self))
    }
}

extension SwiftUIRouter {
    struct InitialView: View {
        @StateObject var router: SwiftUIRouter
        @State var modalView: TestScreenSwiftUI.Route?
        
        var body: some View {
            NavigationStack(path: $router.path) {
                TestScreenSwiftUI(
                    isModal: true,
                    onRoute: {
                    switch $0 {
                    case .onPushAnotherTestScreen:
                        router.path.append($0)
                    case .onPresentAnotherTestScreen:
                        modalView = $0
                    case .onBack:
                        self.router.onRoute?(.onBack)
                    }
                }
                )
                .navigationDestination(for: TestScreenSwiftUI.Route.self, destination: showScreen)
                .sheet(item: $modalView, // or .fullScreenCover
                       onDismiss: { modalView = nil },
                       content: showScreen)
            }
        }
    }
}

// MARK: - FeatureSwiftUI.Route
extension SwiftUIRouter.InitialView {
    @ViewBuilder func showScreen(_ route: TestScreenSwiftUI.Route) -> some View {
        switch route {
        case .onPushAnotherTestScreen:
            AnotherTestScreenSwiftUI()
        case .onPresentAnotherTestScreen:
            AnotherTestScreenSwiftUI()
        case .onBack:
            fatalError("Impossible case")
        }
    }
}


