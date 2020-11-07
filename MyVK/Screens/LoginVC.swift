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
    @IBOutlet weak var rememberMeCheckbox: CheckBox!
    
    
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
                performSegue(withIdentifier: String(describing: MyLoginSegue.self), sender: nil)
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


//
// MARK: - MyLoginSegue
//
class MyLoginSegue: UIStoryboardSegue {
    
    override func perform() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: MyTabBarController.self)
        let myTabBarController = storyboard.instantiateViewController(withIdentifier: identifier) as! MyTabBarController
        myTabBarController.selectedIndex = PersistenceManager.selectedTab
        UIApplication.shared.windows.first?.rootViewController = myTabBarController
    }
}


//
// MARK: - CheckBoxDelegate
//
extension LoginVC: CheckBoxDelegate {
    
    func checkTapped(_ checked: Bool) {
        loginTextField.restorationIdentifier = checked ? "loginTextField" : nil
    }
}
