//
//  Swift+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import Foundation
import RealmSwift

extension Int {
    
    init?(_ optionalString: String?) {
        guard let string = optionalString else { return nil }
        self.init(string)
    }
}


extension String {
    
    init?(_ optionalInt: Int?) {
        guard let int = optionalInt else { return nil }
        self.init(int)
    }
    
    
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


extension Array where Element: Object {
    
    @discardableResult
    mutating func updating(with newElement: Element) -> Bool {
        guard !self.contains(where: { $0.hashValue == newElement.hashValue }) else { return false }
        self.append(newElement)
        return true
    }
    
    
    @discardableResult
    mutating func updating(with newElements: [Element]) -> Bool {
        var updated = false
        newElements.forEach {
            if updating(with: $0) {
                updated = true
            }
        }
        return updated
    }
}


extension Dictionary {
    
    static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        return lhs.merging(rhs) { _, new in new }
    }
}
