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
    @IBOutlet private weak var loginTextField: MyTextField!
    @IBOutlet private weak var passwordTextField: MyTextField!
    @IBOutlet weak var rememberMeCheckbox: Checkbox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle  = .light
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        stackView.isHidden          = true
        rememberMeCheckbox.delegate = self
        
        #if DEBUG
        loginTextField.text     = "79154874184"
        passwordTextField.text  = "12345678"
        #endif
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveStackViewToCenter()
        UIView.transition(with: stackView, duration: 1.2, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            self.stackView.isHidden = false
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        moveStackViewToCenter()
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        checkLoginAndPassword()
    }
    
    
    private func checkLoginAndPassword() -> Bool {
        if loginTextField.text == "79154874184" && passwordTextField.text == "12345678" {
            return true
        } else {
            presentAlert(title: "Некорректный логин/пароль", message: "Пожалуйста, введите логин и пароль.")
            return false
        }
    }
    
    
    private func moveStackViewToCenter() {
        DispatchQueue.main.async {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height  = self.view.bounds.height
            self.scrollView.contentOffset.y     = -(self.view.bounds.height / 2 - self.stackView.bounds.height / 2)
        }}
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
            let viewHeight      = view.bounds.height
            let stackViewHeight = self.stackView.bounds.height
            
            scrollView.contentSize.height                   = viewHeight + keyboardFrame.height
            scrollView.contentInset.bottom                  = -(viewHeight - stackViewHeight)
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
            
            UIView.animate(withDuration: 0.4) {
                self.scrollView.contentOffset.y = -(viewHeight - keyboardFrame.height - stackViewHeight)
            }
        }
    }
    
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
        moveStackViewToCenter()
    }
}


//
// MARK: - LoginSegue
//
final class LoginSegue: UIStoryboardSegue {
    
    override func perform() {
        source.showLoadingView(duration: 10)
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController = self.destination
        }
    }
}


//
// MARK: - CheckBoxDelegate
//
extension LoginVC: CheckboxDelegate {
    
    func checkTapped(_ checkbox: Checkbox, checked: Bool) {
        loginTextField.restorationIdentifier = checked ? "loginTextField" : nil
    }
}
