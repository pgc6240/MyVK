//
//  PhotoCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let reuseId = String(describing: PhotoCell.self)
    
    var photoImageView: UIImageView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    private func layoutUI() {
        photoImageView = UIImageView(frame: contentView.bounds)
        addSubview(photoImageView)
    }
    
    func set(with photo: Photo) {
        photoImageView.contentMode = .scaleAspectFit
        NetworkManager.shared.downloadPhoto(url: photo.maxSizeUrl) { [weak self] photo in
            self?.photoImageView.image = photo
            self?.layoutIfNeeded()
        }
    }
}
