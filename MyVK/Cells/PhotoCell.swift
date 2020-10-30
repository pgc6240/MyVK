//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let reuseId = "PhotoCell"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.random()
    }
}
