//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    static let reuseId = "PhotoCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.random()
    }
    
    func set(with photo: Photo) {
        photoImageView.image = photo.image
    }
}
