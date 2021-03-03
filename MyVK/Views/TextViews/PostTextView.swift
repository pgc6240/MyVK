//
//  PostTextView.swift
//  MyVK
//
//  Created by pgc6240 on 08.02.2021.
//

import UIKit

final class PostTextView: UITextView {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    
    private func configure() {
        textContainer.maximumNumberOfLines  = 8
        textContainer.lineFragmentPadding   = 0
        textContainerInset                  = .zero
    }
}
