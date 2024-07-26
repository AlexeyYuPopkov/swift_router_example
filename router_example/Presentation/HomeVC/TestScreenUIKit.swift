//
//  TestScreenUIKit.swift
//  router_example
//
//  Created by Алексей Попков on 26.07.2024.
//

import UIKit

final class TestScreenUIKit: UIViewController {
    
    let label = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "Test Screen (UIKit)"
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 16.0,
                             y: (view.bounds.height - 50.0) / 2.0,
                             width: view.bounds.width - 32.0,
                             height: 50.0)
    }
}
