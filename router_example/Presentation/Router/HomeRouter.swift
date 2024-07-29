//
//  HomeRouter.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import UIKit
import SwiftUI

final class HomeRouter {
    // 1
    func initialScreen() -> UIViewController {
        let vc = createInitialScreen()
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
}

extension HomeRouter {
    private func createInitialScreen() -> UIViewController {
        // 2
        let vc = HomeVC(nibName: nil, bundle: nil)
        // 3
        vc.onRoute = {
            switch $0 {
            case .pushTestScreenUIKit(let sender):
                self.pushTestScreenUIKit(sender)
            case .presentTestScreenUIKit(let sender):
                self.presentTestScreenUIKit(sender)
            case .onPushTestScreenSwiftUI(let sender):
                self.pushTestScreenSwiftUI(sender)
            case .onPresentTestScreenSwiftUI(let sender):
                self.presentTestScreenSwiftUI(sender)
            }
        }

        return vc
    }
}

// MARK: - Push and Present Test Screen UIKit
// 4
extension HomeRouter {
    private func pushTestScreenUIKit(_ sender: UIViewController) {
        let vc = TestScreenUIKit(nibName: nil, bundle: nil)
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentTestScreenUIKit(_ sender: UIViewController) {
        let vc = TestScreenUIKit(nibName: nil, bundle: nil)
        sender.navigationController?.present(vc, animated: true)
    }
}

// MARK: - Push SwiftUI Test Screen
extension HomeRouter {
    private final class Box {
        weak var vc: UIViewController!
    }
    
    private func pushTestScreenSwiftUI(_ sender: UIViewController) {
        let box = Box()
        
        let view = TestScreenSwiftUI(
            isModal: false,
            onRoute: {
                switch $0 {
                case .onPushAnotherTestScreen:
                    self.pushPushAnotherTestScreen(sender: box)
                case .onPresentAnotherTestScreen:
                    self.presentAnotherTestScreen(sender: box)
                case .onBack:
                    break
                }
            }
        )
        
        let vc = UIHostingController(rootView: view)
        
        // 5
        box.vc = vc
        
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushPushAnotherTestScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherTestScreenSwiftUI())
        sender.vc.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentAnotherTestScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherTestScreenSwiftUI())
        sender.vc.present(vc, animated: true)
    }
}

// MARK: - Present SwiftUI Feature
extension HomeRouter {
    private func presentTestScreenSwiftUI(_ sender: UIViewController) {
        // 6
        let router = SwiftUIRouter()
        
        // 7
        let vc = router.initialScreen()
        vc.modalPresentationStyle = .fullScreen
        
        // 8
        router.onRoute = { [weak vc] in
            switch $0 {
            case .onBack:
                vc?.dismiss(animated: true)
            }
        }
        
        sender.present(vc, animated: true)
    }
}
