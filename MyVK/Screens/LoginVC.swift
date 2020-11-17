//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var rememberMeCheckbox: Checkbox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        stackView.isHidden = true
        rememberMeCheckbox.delegate = self
        
        #if DEBUG
        loginTextField.text     = "79154874184"
        passwordTextField.text  = "12345678"
        #endif
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissKeyboard()
        UIView.transition(with: stackView, duration: 0.7, options: .transitionCrossDissolve) {
            self.stackView.isHidden = false
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        checkLoginAndPassword()
    }
    
    
    func checkLoginAndPassword() -> Bool {
        if loginTextField.text == "79154874184" && passwordTextField.text == "12345678" {
            return true
        } else {
            presentAlert(title: "Некорректный логин/пароль", message: "Пожалуйста, введите логин и пароль.")
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
                performSegue(withIdentifier: String(describing: LoginSegue.self), sender: nil)
            }
        }
        return true
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let viewHeight = view.bounds.height
            let stackViewHeight = self.stackView.bounds.height
            UIView.animate(withDuration: 0.4) {
                self.scrollView.contentSize.height = viewHeight + keyboardFrame.height
                self.scrollView.contentOffset.y = -(viewHeight - keyboardFrame.height - stackViewHeight)
                self.scrollView.contentInset.bottom = -(viewHeight - stackViewHeight)
                self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
            }
        }
    }
    
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.bounds.height
            self.scrollView.contentOffset.y = -(self.view.bounds.height / 2 - self.stackView.bounds.height / 2)
        }
    }
}


//
// MARK: - LoginSegue
//
final class LoginSegue: UIStoryboardSegue {
    
    override func perform() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: TabBarController.self)
        let tabBarController = storyboard.instantiateViewController(identifier: identifier)
        UIApplication.shared.windows.first?.rootViewController = tabBarController
    }
}


//
// MARK: - CheckBoxDelegate
//
extension LoginVC: CheckboxDelegate {
    
    func checkTapped(_ checked: Bool) {
        loginTextField.restorationIdentifier = checked ? "loginTextField" : nil
    }
}
