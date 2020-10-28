//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var containerCenterYConstraint: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.layer.cornerRadius        = 15
        loginTextField.delegate                 = self
        passwordTextField.delegate              = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        checkLoginAndPassword()
    }
    
    func checkLoginAndPassword() -> Bool {
        if loginTextField.text == "1234" && passwordTextField.text == "1234" {
            return true
        } else {
            let alert = UIAlertController(title: "Некорректный логин/пароль", message: "Пожалуйста, введите логин и пароль.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Хорошо", style: .cancel))
            present(alert, animated: true)
            return false
        }
    }
}

//
// MARK: - UITextFieldDelegate
//
extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            dismissKeyboard()
            if checkLoginAndPassword() {
                performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeContainerCenterY(toConstant: -45)
    }
    
    @objc func dismissKeyboard() {
        changeContainerCenterY(toConstant: 0)
        view.endEditing(true)
    }

    func changeContainerCenterY(toConstant constant: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerCenterYConstraint?.constant = constant
            self.view.layoutIfNeeded()
        }
    }
}

