//
//  Swift+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import Foundation

extension Int {
    
    var isEven: Bool { self % 2 == 0 }
}


extension String {
    
    var isValidPhoneNumber: Bool {
        let phoneNumberFormat    = "^((\\+7|7|8)+([0-9]){10})$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberFormat)
        return phoneNumberPredicate.evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        let emailFormat    = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        let passwordFormat    = ".{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: self)
    }
    
    var toLatin: String {
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false) ?? self
        return latinString.applyingTransform(StringTransform.stripDiacritics, reverse: false) ?? self
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}


extension Array where Element == String {
    
    var localized: Array<String> {
        self.map { $0.localized }
    }
}
