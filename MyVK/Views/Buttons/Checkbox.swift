//
//  Checkbox.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import UIKit

protocol CheckboxDelegate: class {
    func checkTapped(_ checkbox: Checkbox, checked: Bool)
}

final class Checkbox: UIButton {

    weak var delegate: CheckboxDelegate?
    var checked = false { willSet(checked) { imageView?.tintColor = checked ? tintColor : .clear }}
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        decodeRestorableState(with: coder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.layer.borderWidth = 1
        imageView?.layer.borderColor = titleLabel?.textColor.cgColor
    }
    
    private func configure() {
        addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        imageView?.tintColor = checked ? tintColor : .clear
    }

    @objc func checkmarkTapped() {
        checked.toggle()
        delegate?.checkTapped(self, checked: checked)
    }
}


//
// MARK: - State Preservation
//
extension Checkbox {
    
    override func encodeRestorableState(with coder: NSCoder) {
        guard let restorationIdentifier = restorationIdentifier else { return }
        super.encodeRestorableState(with: coder)
        coder.encode(checked, forKey: restorationIdentifier)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let restorationIdentifier = restorationIdentifier else { return }
        super.decodeRestorableState(with: coder)
        checked = coder.decodeBool(forKey: restorationIdentifier)
    }
}
