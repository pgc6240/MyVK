//
//  AlphabetPicker.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

protocol AlphabetPickerDelegate: class {
    func letterTapped(_ letter: String)
}


final class AlphabetPicker: UIControl {
    
    weak var delegate: AlphabetPickerDelegate?

    var letters                 = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ"
    var lettersInRow: CGFloat   = 6
    var rowCount: CGFloat       = 1
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    init(with letters: String, in superview: UIView) {
        
        rowCount    = (CGFloat(letters.count) / lettersInRow).rounded(.up)
        let width   = lettersInRow * 44
        let height  = rowCount * 44
        let originX = superview.bounds.midX - width / 2
        let originY = superview.bounds.midY - height / 2
       
        super.init(frame: CGRect(x: originX, y: originY, width: width, height: height))
        self.letters = letters
        layoutUI()
    }

    
    private func layoutUI() {
        backgroundColor = .systemGray4
        
        for (i, letter) in letters.uppercased().sorted(by: <).enumerated() {
            
            let lettersInRow    = Int(self.lettersInRow)
            let currentRow      = i / lettersInRow
            let originX         = (i - currentRow * lettersInRow) * 44
            let letterButton    = UIButton(frame: CGRect(x: originX, y: currentRow * 44, width: 44, height: 44))
            
            letterButton.setTitle(String(letter), for: .normal)
            letterButton.setTitleColor(.label, for: .normal)
            letterButton.addTarget(self, action: #selector(letterButtonTapped(_:)), for: .touchUpInside)
            
            addSubview(letterButton)
        }
    }
    
    @objc func letterButtonTapped(_ letterButton: UIButton) {
        guard let letter = letterButton.currentTitle else { return }
        delegate?.letterTapped(letter)
    }
}
