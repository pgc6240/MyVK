//
//  Foundation+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import Foundation
import UIKit

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
    
    
    var toUrl: URL? {
        URL(string: self)
    }
    
    
    init?(_ optionalInt: Int?) {
        guard let int = optionalInt else { return nil }
        self.init(int)
    }
    
    
    func size(in width: CGFloat, font: UIFont = .preferredFont(forTextStyle: .body)) -> CGSize {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
}


extension Dictionary {
    
    static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        return lhs.merging(rhs) { _, new in new }
    }
}


extension URL {
    
    var parameters: [String: String]? {
        (self.query ?? self.fragment)?
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) {
                var parameters    = $0
                parameters[$1[0]] = $1[1]
                return parameters
            }
    }
    
    
    init?(string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
}


extension Optional where Wrapped == Character {
    
    var toString: String? {
        guard let character = self else { return nil }
        return String(character)
    }
}


extension Locale {
    
    static var isEnglishLocale: Bool {
        Locale.current.identifier == "en" || Locale.current.identifier == "en_US"
    }
    
    
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
