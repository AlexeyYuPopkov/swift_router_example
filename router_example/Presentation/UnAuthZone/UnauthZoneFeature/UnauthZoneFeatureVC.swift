//
//  UnauthZoneFeatureVC.swift
//  router_example
//
//  Created by Алексей Попков on 25.07.2024.
//

import UIKit

final class UnauthZoneFeatureVC: UIViewController, OnRouteProtocol {
   private let button = UIButton(frame: .zero)
    private let parameter: Int
    
    var onRoute: ((Route) -> Void)?
    
    init(parameter: Int) {
        self.parameter = parameter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.titleLabel?.text = "\(parameter)"
        view.addSubview(button)
        
        button.setTitle("Next \(parameter)", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.setTitleColor(.gray, for: .selected)
        button.setTitleColor(.gray, for: .highlighted)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.textAlignment = .center
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        navigationItem.title = "A Future \(parameter)"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .white
        button.frame = .init(x: 16.0,
                            y: (view.bounds.height - 50.0) / 2.0 ,
                            width: view.bounds.width - 32.0,
                            height: 50.0)
        
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        onRoute?(.onNext(self, parameter: self.parameter + 1))
    }
}

extension UnauthZoneFeatureVC {
    enum Route {
        case onNext(UIViewController, parameter: Int)
    }
}
