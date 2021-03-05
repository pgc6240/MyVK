//
//  URLDownloadableImage.swift
//  MyVK
//
//  Created by pgc6240 on 26.02.2021.
//

import UIKit

protocol URLDownloadableImage: class {
    var image: UIImage? { get set }
    var downloadURLString: String? { get set }
    var downloadImageOperation: DownloadImageOperation? { get set }
    func downloadImage(with downloadURLString: String?)
    func prepareForReuse()
    func reloadImage()
}

extension URLDownloadableImage {
    
    func downloadImage(with downloadURLString: String?) {
        guard let downloadImageOperation = DownloadImageOperation(downloadURLString) else { return }
        self.downloadURLString      = downloadURLString
        self.downloadImageOperation = downloadImageOperation
        downloadImageOperation.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                self?.image = downloadImageOperation.downloadedImage
            }
        }
        OperationQueue().addOperation(downloadImageOperation)
    }
    
    func prepareForReuse() {
        image = nil
        downloadImageOperation?.cancel()
    }
    
    func reloadImage() {
        downloadImage(with: downloadURLString)
    }
}
