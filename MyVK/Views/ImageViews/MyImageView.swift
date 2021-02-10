//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

final class MyImageView: UIImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .secondarySystemBackground
    }
    
    
    // MARK: - Storyboard-editable propeties -
    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { layer.cornerRadius = newValue }
    }
    
    
    // MARK: - Spring in zoom animation -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }
    
    
    // MARK: - Downloading-related stuff -
    private var downloadImageOperation: DownloadImageOperation?
    private let operationQueue = OperationQueue()
    
    func prepareForReuse() {
        image = nil
        downloadImageOperation?.cancel()
    }
    
    func downloadImage(with urlString: String?) {
        downloadImageOperation?.cancel()
        downloadImageOperation = DownloadImageOperation(urlString)
        guard let downloadImageOperation = downloadImageOperation else { return }
        operationQueue.addOperation(downloadImageOperation)
        downloadImageOperation.completionBlock = {
            OperationQueue.main.addOperation { [weak self] in
                self?.image = downloadImageOperation.downloadedImage
                self?.backgroundColor = .clear
            }
        }
    }
}
