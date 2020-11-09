//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet weak var loginTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var rememberMeCheckbox: Checkbox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rememberMeCheckbox.delegate = self
        
        #if DEBUG
        loginTextField.text     = "79154874184"
        passwordTextField.text  = "12345678"
        #endif
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
    
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
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
