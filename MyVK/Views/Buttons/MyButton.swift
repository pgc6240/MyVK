//
//  MyButton.swift
//  MyVK
//
//  Created by pgc6240 on 16.02.2021.
//

import UIKit

final class MyButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width + 20, height: super.intrinsicContentSize.height + 5)
    }
}
