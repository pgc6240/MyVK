//
//  Foundation+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import Foundation
import RealmSwift
import UIKit

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
    
    var toUrl: URL? {
        URL(string: self)
    }
    
    
    func size(maxWidth: CGFloat, font: UIFont) -> CGSize {
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
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


extension Optional where Wrapped == URL {
    
    var parameters: [String: String]? {
        self?.query?
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) {
                var parameters    = $0
                parameters[$1[0]] = $1[1]
                return parameters
            }
    }
}


extension Locale {
    
    static var isEnglishLocale: Bool { Locale.current.identifier == "en" || Locale.current.identifier == "en_US" }
    
    static var identifierShort: String {
        switch Locale.current.identifier {
        case "en_US":
            return "en"
        case "ru_RU", "ru_US":
            return "ru"
        default:
            return Locale.current.identifier
        }
    }
}


extension Optional where Wrapped == Character {
    
    var toString: String? {
        guard let character = self else { return nil }
        return String(character)
    }
}


extension URL {
    
    init?(string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
}
