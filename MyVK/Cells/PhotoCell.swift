//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: ClearImageView!
    
    
    func set(with photo: Photo) {
        photoImageView.downloadImage(with: photo.maxSizeUrl)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.prepareForReuse()
    }
}


// MARK: - UIScrollViewDelegate -
extension PhotoCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        photoImageView
    }
}
