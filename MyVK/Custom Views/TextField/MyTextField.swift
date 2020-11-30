//
//  MyTextField.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

final class MyTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: super.intrinsicContentSize.height + 5)
    }

    private func configure() {
        backgroundColor     = .tertiarySystemBackground
        textColor           = .label
        tintColor           = .vkColor
        
        font                = .preferredFont(forTextStyle: .body)
        
        layer.cornerRadius  = 8
        layer.borderWidth   = 2
        layer.borderColor   = UIColor.secondarySystemFill.cgColor
        
        autocorrectionType  = .no
        clearButtonMode     = .whileEditing
    }
}


//
// MARK: - State Preservation
//
extension MyTextField {
    
    override func encodeRestorableState(with coder: NSCoder) {
        guard let restorationIdentifier = restorationIdentifier else { return }
        super.encodeRestorableState(with: coder)
        coder.encode(text, forKey: restorationIdentifier)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let restorationIdentifier = restorationIdentifier else { return }
        super.decodeRestorableState(with: coder)
        text = coder.decodeObject(forKey: restorationIdentifier) as? String
    }
}
