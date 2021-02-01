//
//  SecondaryPlaceholderLabel.swift
//  MyVK
//
//  Created by pgc6240 on 01.02.2021.
//

import UIKit

final class SecondaryPlaceholderLabel: PlaceholderLabel {
    
    override var text: String? {
        didSet {
            textColor = text == "" ? .secondarySystemBackground : .secondaryLabel
            backgroundColor = text == "" ? .secondarySystemBackground : .systemBackground
        }
    }
}
