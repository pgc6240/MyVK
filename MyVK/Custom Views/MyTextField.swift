//
//  MyTextField.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

final class MyTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor     = .tertiarySystemBackground
        textColor           = .label
        tintColor           = UIColor(named: "vk-color")
        
        font                = .preferredFont(forTextStyle: .body)
        
        layer.cornerRadius  = 8
        layer.borderWidth   = 2
        layer.borderColor   = UIColor.secondarySystemFill.cgColor
        
        autocorrectionType  = .no
    }
}
