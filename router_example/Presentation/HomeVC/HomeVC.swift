//
//  HomeVC.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

final class HomeVC: UIViewController, OnRouteProtocol {
    var onRoute: ((Route) -> Void)?
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    lazy var dataSource = createDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
}

// MARK: - Table DataSource
extension HomeVC {
    static let CellReuseIdentifier = "CellReuseIdentifier"
    
    enum Section {
        case uikit
        case swiftui
    }
    
    enum Row {
        case pushTestScreenUIKit
        case presentTestScreenUIKit
        case pushTestScreenSwiftUI
        case presentTestScreenSwiftUI
    }
    
    static let sections: [Section] = [.uikit, .swiftui]
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    func createDataSource() -> DataSource {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.CellReuseIdentifier)
        
        let result = DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .pushTestScreenUIKit, .presentTestScreenUIKit,
                    .pushTestScreenSwiftUI, .presentTestScreenSwiftUI:
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.CellReuseIdentifier,
                                                         for: indexPath)
                cell.backgroundColor = .white
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = item.title
                return cell
                
            }
        }
        return result
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Self.sections)
        snapshot.appendItems([
            .pushTestScreenUIKit,
            .presentTestScreenUIKit
        ], toSection: .uikit)
        
        snapshot.appendItems([
            .pushTestScreenSwiftUI,
            .presentTestScreenSwiftUI
        ], toSection: .swiftui)
        
        dataSource.apply(snapshot)
    }
}

extension HomeVC.Row {
    var title: String {
        switch self {
        case .pushTestScreenUIKit:
            return "Push Test Screen (UIKit)"
        case .presentTestScreenUIKit:
            return "Present Test Screen (UIKit)"
        case .pushTestScreenSwiftUI:
            return "Push Test Screen (SwiftUI)"
        case .presentTestScreenSwiftUI:
            return "Present Test Screen (SwiftUI)"
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
        case .pushTestScreenUIKit:
            onRoute?(.pushTestScreenUIKit(self))
        case .presentTestScreenUIKit:
            onRoute?(.presentTestScreenUIKit(self))
        case .pushTestScreenSwiftUI:
            onRoute?(.onPushTestScreenSwiftUI(self))
        case .presentTestScreenSwiftUI:
            onRoute?(.onPresentTestScreenSwiftUI(self))
        }
    }
}

// MARK: - Routing
extension HomeVC {
    enum Route {
        case pushTestScreenUIKit(_ sender: UIViewController)
        case presentTestScreenUIKit(_ sender: UIViewController)
        case onPresentTestScreenSwiftUI(_ sender: UIViewController)
        case onPushTestScreenSwiftUI(_ sender: UIViewController)
    }
}
