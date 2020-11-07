//
//  CheckBox.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import UIKit

final class CheckBox: UIButton {

    var checked = false {
        willSet(checked) {
            imageView?.tintColor = checked ? tintColor : .white
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        guard let restorationIdentifier = restorationIdentifier else { return }
        checked = coder.decodeBool(forKey: restorationIdentifier)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        guard let restorationIdentifier = restorationIdentifier else { return }
        coder.encode(checked, forKey: restorationIdentifier)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        guard let restorationIdentifier = restorationIdentifier else { return }
        checked = coder.decodeBool(forKey: restorationIdentifier)
    }
    
    private func configure() {
        addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        imageView?.tintColor = checked ? tintColor : .white
        imageView?.layer.borderWidth = 1
    }
    
    @objc func checkmarkTapped() {
        checked.toggle()
    }
}
