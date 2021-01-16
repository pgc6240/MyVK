//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let reuseId = String(describing: PhotoCell.self)
    
    @IBOutlet weak var photoImageView: MyImageView!
    
    
    func set(with photo: Photo) {
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.downloadImage(url: photo.maxSizeUrl ?? "")
    }
}
