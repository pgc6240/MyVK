//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var loginTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var containerCenterYConstraint: NSLayoutConstraint?
    
    var isRememberMeChecked: Bool? = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    override func encodeRestorableState(with coder: NSCoder) {
        //coder.encode(isRememberMeChecked, forKey: "rememberMe")
        //coder.encode(loginTextField.text, forKey: "login")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        //isRememberMeChecked = coder.decodeObject(forKey: "rememberMe") as? Bool
        //loginTextField.text = coder.decodeObject(forKey: "login") as? String ?? "79154874184"
        super.decodeRestorableState(with: coder)
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
    
    
    func changeContainerCenterY(toConstant constant: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerCenterYConstraint?.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func dismissKeyboard() {
        changeContainerCenterY(toConstant: 0)
        view.endEditing(true)
    }
}

 
class MySegue: UIStoryboardSegue {
    
    override func perform() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootTabBarController = storyboard.instantiateViewController(withIdentifier: "rootTabBarController")
        UIApplication.shared.windows.first?.rootViewController = rootTabBarController
    }
}
