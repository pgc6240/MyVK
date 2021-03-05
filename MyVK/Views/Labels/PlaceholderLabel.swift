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
            configure()
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        text = "Placeholder"
    }
    
    
    func configure() {
        textColor       = text == "Placeholder" ? .secondarySystemBackground : .label
        backgroundColor = text == "Placeholder" ? .secondarySystemBackground : .clear
    }
}
