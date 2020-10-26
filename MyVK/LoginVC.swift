//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    
    private var containerYposition: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    
    private func configureVC() {
        view.backgroundColor                = .systemBackground
        containerYposition                  = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        containerYposition?.isActive        = true
        logoImageView.layer.cornerRadius    = 15
        loginTextField.delegate             = self
        passwordTextField.delegate          = self
        addTapGestureToDismissKeyboard()
    }
}


// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        changeContainerYposition(toConstant: 0)
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeContainerYposition(toConstant: -45)
    }
    
    
    @objc func dismissKeyboard() {
        changeContainerYposition(toConstant: 0)
        view.endEditing(true)
    }
    
    
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    private func changeContainerYposition(toConstant constant: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerYposition?.constant = constant
            self.view.layoutIfNeeded()
        }
    }
}

