//
//  UIColor+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        UIColor(red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1)
    }
}
