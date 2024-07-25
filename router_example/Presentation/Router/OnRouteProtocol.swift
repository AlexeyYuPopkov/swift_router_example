//
//  OnRouteProtocol.swift
//  router_example
//
//  Created by Алексей Попков on 24.07.2024.
//

import UIKit

/// OnRouteProtocol usage example
///
///final class ViewController: UIViewController, OnRouteProtocol {
///    var onRoute: ((Route) -> Void)?
///
///    // ... layout is ommited
///
///    @objc func onFeature1ButtonAction(sender: UIButton) {
///        onRoute?(.onFeature1(self))
///    }
///
///    @objc func onFeature2ButtonAction(sender: UIButton) {
///        onRoute?(.onFeature2(self))
///    }
///}
///
///extension ViewController {
///    enum Route {
///        case onFeature1(ViewController)
///        case onFeature2(ViewController)
///    }
///}

protocol OnRouteProtocol {
    associatedtype Route
    /// if  [onRoute] will setup to UIViewController than  [onRoute]  should capture [self] (without [weak] keyword) to implicitly maintain router
    var onRoute: ((Route) -> Void)? { get set }
}


