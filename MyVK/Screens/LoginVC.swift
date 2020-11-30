//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var loginTextField: MyTextField!
    @IBOutlet private weak var passwordTextField: MyTextField!
    @IBOutlet private weak var rememberMeCheckbox: Checkbox!
    
    fileprivate var loginError: LoginError? { willSet(error) { presentAlert(title: error?.name, message: error?.message) }}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        stackView.isHidden          = true
        rememberMeCheckbox.delegate = self
        
        #if DEBUG
        loginTextField.text    = "79154874184"
        passwordTextField.text = "12345678"
        #endif
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveStackViewToCenter()
        UIView.transition(with: stackView, duration: 1, options: [.transitionCrossDissolve, .allowUserInteraction]) {
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
    
    
    private func moveStackViewToCenter() {
        DispatchQueue.main.async {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.bounds.height
            self.scrollView.contentOffset.y    = -(self.view.bounds.height / 2 - self.stackView.bounds.height / 2)
        }}
    }
    
    
    private func checkLoginAndPassword() -> Bool {
        
        func performChecks() throws {
            guard var enteredLogin = loginTextField.text, let enteredPassword = passwordTextField.text else {
                return
            }
            
            if enteredLogin.isProbablyEmail {
                guard enteredLogin.isValidEmail else {
                    throw LoginError.invalidEmail
                }
            } else {
                enteredLogin.removeCharacters(" ", "+", "(", ")", "-")
                guard enteredLogin.isValidPhoneNumber else {
                    throw LoginError.invalidPhoneNumber
                }
            }
            
            guard enteredPassword.isValidPassword else {
                throw LoginError.invalidPassword
            }
            
            guard enteredLogin == "79154874184" && enteredPassword == "12345678" else {
                throw LoginError.invalidCredentials
            }
        }

        do {
            try performChecks()
            return true
        } catch {
            loginError = error as? LoginError
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
        
        } else if checkLoginAndPassword() {
            performSegue(withIdentifier: String(describing: LoginSegue.self), sender: nil)
        }
        
        return true
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let viewHeight      = view.bounds.height
            let stackViewHeight = stackView.bounds.height
            
            scrollView.contentOffset.y                      = -(viewHeight - keyboardFrame.height - stackViewHeight)
            scrollView.contentSize.height                   = viewHeight + keyboardFrame.height
            scrollView.contentInset.bottom                  = -(viewHeight - stackViewHeight)
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        }
    }
    
    
    @IBAction private func dismissKeyboard() {
        view.endEditing(true)
        moveStackViewToCenter()
    }
}


//
// MARK: - LoginSegue
//
final class LoginSegue: UIStoryboardSegue {
    
    override func perform() {
        source.showLoadingView(duration: .infinity)
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


//
// MARK: - LoginError
//
fileprivate enum LoginError: String, LocalizedError {
    
    case invalidCredentials = "Неправильный\nлогин и/или пароль"
    case invalidPassword    = "Некорректный пароль"
    case invalidEmail       = "Некорректный e-mail"
    case invalidPhoneNumber = "Некорректный номер телефона"
    
    
    var name: String        { rawValue.localized }
    var message: String?    { recoverySuggestion?.localized }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:   return "\nПожалуйста, проверьте введённый логин и пароль."
        case .invalidPassword:      return "\nПароль должен содержать более восьми символов."
        case .invalidEmail:         return "\nE-mail может содержать буквы, цифры, точку и символы: _, %, +, -."
        case .invalidPhoneNumber:   return "\nНомер телефона может содержать цифры, пробелы и символы: +, (, ), -."
        }
    }
}
