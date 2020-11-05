//
//  AvatarImageView.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

@IBDesignable
final class AvatarImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { layer.cornerRadius = newValue }
    }
}
