//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 06.11.2020.
//

import UIKit

@IBDesignable
final class MyImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { layer.cornerRadius = newValue }
    }
}
