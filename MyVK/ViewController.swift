//
//  ViewController.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginTextField: MyTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor                = .systemBackground
        logoImageView.layer.cornerRadius    = 15
        loginTextField.delegate             = self
        addTapGestureToDismissKeyboard()
    }
}


// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        updateContainerYposition(constant: 0)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateContainerYposition(constant: -45)
    }
    
    @objc func dismissKeyboard() {
        updateContainerYposition(constant: 0)
        view.endEditing(true)
    }
    
    func addTapGestureToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func updateContainerYposition(constant: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.view.constraints.first { $0.identifier == "containerYconstraint" }?.constant = constant
            self.view.layoutIfNeeded()
        }
    }
}

