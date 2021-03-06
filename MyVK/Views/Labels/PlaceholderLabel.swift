//
//  PlaceholderLabel.swift
//  MyVK
//
//  Created by pgc6240 on 01.02.2021.
//

import UIKit

class PlaceholderLabel: UILabel {
    
    override var text: String? {
        didSet {
            textColor = text == "" ? .secondarySystemBackground : .label
            backgroundColor = text == "" ? .secondarySystemBackground : .systemBackground
        }
    }
}
