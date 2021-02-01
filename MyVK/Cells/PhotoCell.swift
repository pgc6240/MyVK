//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var photoImageView: MyImageView!
    
    
    func set(with photo: Photo) {
        photoImageView.downloadImage(with: photo.maxSizeUrl)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.prepareForReuse()
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        photoImageView
    }
}
