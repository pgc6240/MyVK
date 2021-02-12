//
//  SecondaryPlaceholderLabel.swift
//  MyVK
//
//  Created by pgc6240 on 01.02.2021.
//

import UIKit

final class SecondaryPlaceholderLabel: PlaceholderLabel {
    
    override func configure() {
        textColor = text == "Placeholder" ? .secondarySystemBackground : .secondaryLabel
        backgroundColor = text == "Placeholder" ? .secondarySystemBackground : .systemBackground
    }
}
