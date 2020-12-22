//
//  Swift+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import Foundation

extension Int {
    
    init?(_ optionalString: String?) {
        guard let string = optionalString else { return nil }
        self.init(string)
    }
}


extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    
    var toLatin: String {
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false) ?? self
        return latinString.applyingTransform(StringTransform.stripDiacritics, reverse: false) ?? self
    }
}


extension Array where Element == String {
    
    var localized: Array<String> {
        self.map { $0.localized }
    }
}


extension Dictionary {
    
    static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        return lhs.merging(rhs) { _, new in new }
    }
}
