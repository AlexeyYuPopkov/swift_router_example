//
//  HomeVC.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import MBProgressHUD

final class HomeVC: UIViewController, OnRouteProtocol {
    var bag = Set<AnyCancellable>()
    var onRoute: ((Route) -> Void)?
    let vm: HomeVM
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    lazy var dataSource = createDataSource()

    init(vm: HomeVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSubscriptions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .white
        tableView.frame = view.bounds
    }
}

// MARK: - Setup

extension HomeVC {
    private func setup() {
        view.backgroundColor = .white
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        applySnapshot()
    }
    
    private func setupSubscriptions() {
        vm.stateSignal
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleStateStatus(state: $0)
        }.store(in: &bag)
    }
    
   private func setLoadingIndicator(visible: Bool) {
        if visible {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.accessibilityIdentifier = "LoadingIndicator"
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func handleStateStatus(state: HomeVM.State) {
        setLoadingIndicator(visible: state.status.isLoading)
        
        switch state.status {
        case .loading:
            break
        case .error(_):
            // TODO: show error
            break
        case .common:
            break
        case .didLogout:
            onRoute?(.onLogout(self))
        }
    }
}

// MARK: - Table DataSource
extension HomeVC {
    enum Section {
        case main
    }
    
    enum Row {
        case presentFeatureSwiftUI
        case pushFeatureSwiftUI
        case logout
    }
    
    static let sections: [Section] = [.main]
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    func createDataSource() -> DataSource {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FooterSectionCell")
        
        let result = DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in

            switch itemIdentifier {
                
            case .presentFeatureSwiftUI, .pushFeatureSwiftUI, .logout:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FooterSectionCell", for: indexPath)
                cell.backgroundColor = .white
                                cell.textLabel?.textAlignment = .center
                                cell.textLabel?.numberOfLines = 0
                             
                cell.textLabel?.text = itemIdentifier.title
                return cell

            }
        }
        return result
    }
    
  private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Self.sections)
        snapshot.appendItems([
            .presentFeatureSwiftUI,
            .pushFeatureSwiftUI,
            .logout
        ], toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension HomeVC.Row {
    var title: String {
        switch self {
        case .presentFeatureSwiftUI:
            return "Present Feature SwiftUI"
        case .pushFeatureSwiftUI:
            return "Push Feature SwiftUI"
        case .logout:
            return "Logout"
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch row {
        case .presentFeatureSwiftUI:
            onRoute?(.onPresentFeatureSwiftUI(self))
        case .pushFeatureSwiftUI:
            onRoute?(.onPushFeatureSwiftUI(self))
        case .logout:
            logout()

        }
    }
}

// MARK: - Actions

extension HomeVC {
    private func logout() {
        vm.logout()
    }
}

// MARK: - Routing

extension HomeVC {
    enum Route {
        case onPresentFeatureSwiftUI(_ sender: UIViewController)
        case onPushFeatureSwiftUI(_ sender: UIViewController)
        case onLogout(_ sender: UIViewController)
    }
}
