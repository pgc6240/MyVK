//
//  Formatters.swift
//  MyVK
//
//  Created by pgc6240 on 22.01.2021.
//

import Foundation

enum F { // Formatters
    
    static let df: DateFormatter = {
        let df        = DateFormatter()
        df.locale     = Locale.current
        df.dateFormat = "d MMM yyyy"
        return df
    }()
    
    static let nf: NumberFormatter = {
        let nf               = NumberFormatter()
        nf.numberStyle       = .decimal
        nf.groupingSeparator = ","
        return nf
    }()
    
    static func fd(_ date: Int) -> String { // format date: 237667436432 -> 15 Jan 2015
        let ti = TimeInterval(date)
        let date = Date(timeIntervalSince1970: ti)
        return df.string(from: date)
    }
    
    static func fn(_ number: Int?) -> String? { // format number: 1000 -> 1,000
        guard let number = number else { return nil }
        return nf.string(from: NSNumber(value: number))
    }
}
