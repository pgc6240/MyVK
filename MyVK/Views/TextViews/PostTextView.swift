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
        let padding = textContainer.lineFragmentPadding
        textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
    }
}
