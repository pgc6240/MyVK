//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    static let reuseId = String(describing: PhotoCell.self)
    
    @IBOutlet var photoImageView: UIImageView!
    
    
    func set(with photo: Photo) {
        photoImageView = UIImageView(frame: contentView.bounds)
        photoImageView.image = photo.image
        addSubview(photoImageView)
    }
}
