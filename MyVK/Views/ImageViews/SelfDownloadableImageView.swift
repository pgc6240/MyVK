//
//  SelfDownloadableImageView.swift
//  MyVK
//
//  Created by pgc6240 on 23.02.2021.
//

import UIKit

class SelfDownloadableImageView: UIImageView {
    
    private let operationQueue = OperationQueue()
    private var downloadURLString: String?
    
    
    func downloadImage(with downloadURLString: String?) {
        guard let downloadImageOperation = DownloadImageOperation(downloadURLString) else { return }
        self.downloadURLString = downloadURLString
        operationQueue.cancelAllOperations()
        operationQueue.addOperation(downloadImageOperation)
        downloadImageOperation.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                self?.image = downloadImageOperation.downloadedImage
            }
        }
    }
    
    func reloadImage() {
        downloadImage(with: downloadURLString)
    }
    
    func prepareForReuse() {
        operationQueue.cancelAllOperations()
        image = nil
    }
}
