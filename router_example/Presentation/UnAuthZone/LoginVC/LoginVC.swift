//
//  LoginVC.swift
//  DiStorage_Example
//
//  Created by Alexey Popkov on 08.01.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import MBProgressHUD

final class LoginVC: UIViewController, OnRouteProtocol {

    let loginUsecase: LoginUsecase
    var onRoute: ((Route) -> Void)?

    lazy var titleLabel = UILabel(frame: .zero)
    lazy var descriptionLabel = UILabel(frame: .zero)
    lazy var nameTextField = UITextField(frame: .zero)
    lazy var passwordTextField = UITextField(frame: .zero)
    lazy var button = UIButton(type: .custom)

    init(loginUsecase: LoginUsecase) {
        self.loginUsecase = loginUsecase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAccessibilityIdentifiers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        titleLabel.text = "Login"
        titleLabel.frame = .init(
            x: 16.0,
            y: view.bounds.height / 3.0,
            width: max(.zero, view.bounds.width - 32.0),
            height: 32.0
        )

        descriptionLabel.text = "Input any login and any password"
        descriptionLabel.frame = .init(
            x: 16.0,
            y: titleLabel.frame.maxY + 16.0,
            width: max(.zero, view.bounds.width - 32.0),
            height: 32.0
        )

        nameTextField.frame = .init(
            x: 16.0,
            y: descriptionLabel.frame.maxY + 16.0,
            width: max(.zero, view.bounds.width - 32.0),
            height: 50.0
        )

        passwordTextField.frame = .init(
            x: 16.0,
            y: nameTextField.frame.maxY + 16.0,
            width: max(.zero, view.bounds.width - 32.0),
            height: 50.0
        )

        let buttonSize = button.systemLayoutSizeFitting(
            .init(
                width: max(.zero, view.bounds.width - 32.0),
                height: 44.0
            ),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )

        button.frame = .init(
            x: max(16.0, (view.bounds.width - buttonSize.width) / 2.0),
            y: passwordTextField.frame.maxY + 16.0,
            width: buttonSize.width,
            height: 32.0
        )
    }
}

// MARK: - Setup
extension LoginVC {
    private func setup() {
        view.backgroundColor = .white
        
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        descriptionLabel.font = UIFont.systemFont(ofSize: 11.0)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray
        view.addSubview(descriptionLabel)

        nameTextField.borderStyle = .line
        nameTextField.keyboardType = .default
        nameTextField.delegate = self
        view.addSubview(nameTextField)

        passwordTextField.borderStyle = .line
        passwordTextField.keyboardType = .default
        passwordTextField.delegate = self
        view.addSubview(passwordTextField)

        button.isEnabled = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.setTitleColor(.gray, for: .selected)
        button.setTitleColor(.gray, for: .highlighted)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    private func setupAccessibilityIdentifiers() {
        view.accessibilityIdentifier = "LoginVC"
        titleLabel.accessibilityIdentifier = "TitleLabel.AccessibilityId"
        descriptionLabel.accessibilityIdentifier = "DescriptionLabel.AccessibilityId"
        nameTextField.accessibilityIdentifier = "NameTextField.AccessibilityId"
        passwordTextField.accessibilityIdentifier = "PasswordTextField.AccessibilityId"
        button.accessibilityIdentifier = "SendButton.AccessibilityId"
    }
}

// MARK: - Actions
extension LoginVC {
    @objc func buttonAction(_ sender: UIButton) {
        let login = nameTextField.text
        let password = passwordTextField.text

        guard let login, let password,
              !login.isEmpty, !password.isEmpty else {
            return
        }

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.accessibilityIdentifier = "LoadingIndicator"

        loginUsecase.execute(
            login: login,
            password: password)
        { result in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }

            switch result {
                case .success:
                    self.onRoute?(.onAuth(self))
                case .failure:
                    // TODO: handle error
                    break
            }
        }
    }
}

// MARK: - Setup
extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let oldStr = textField.text ?? ""
        let newStr = (oldStr as NSString).replacingCharacters(in: range, with: string)

        if textField == nameTextField {
            button.isEnabled = !newStr.isEmpty && passwordTextField.text?.isEmpty == false
        } else if textField == passwordTextField {
            button.isEnabled = !newStr.isEmpty && nameTextField.text?.isEmpty == false
        }

        return true
    }


}

// MARK: - Routing
extension LoginVC {
    enum Route {
        case onAuth(_ sender: UIViewController)
    }
}
