//
//  AlphabetControl.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

final class AlphabetControl: UIControl {

    let letters = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ"
    var letterButtons: [String: UIButton] = [:]
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    private func layoutUI() {
        backgroundColor = .systemGray4
        for (i, letter) in letters.enumerated() {
            let lettersInRow = 6
            let row = i / lettersInRow
            let originX = (i - row * lettersInRow) * 44
            let letterButton = UIButton(frame: CGRect(x: originX, y: row * 44, width: 44, height: 44))
            letterButton.setTitle(String(letter), for: .normal)
            letterButton.setTitleColor(.black, for: .normal)
            letterButton.addTarget(self, action: #selector(letterButtonTapped(_:)), for: .touchUpInside)
            addSubview(letterButton)
            letterButtons[String(letter)] = letterButton
        }
    }
    
    @objc func letterButtonTapped(_ letterButton: UIButton) {
        print(letterButton.currentTitle!)
    }
}
