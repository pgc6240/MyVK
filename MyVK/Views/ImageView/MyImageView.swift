//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

final class MyImageView: UIImageView {
    
    // MARK: - Storyboard-editable propeties
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
    private weak var task: URLSessionDataTask?
    
    func prepareForReuse() {
        image = nil
        task?.cancel()
    }
    
    func downloadImage(with urlString: String?) {
        guard
            let urlString = urlString,
            let url = URL(string: urlString) else {
            return
        }
        
        task = urlSession.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.image = UIImage(data: data)
            }
        }
        task?.resume()
    }
}


fileprivate let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    let MB = 1024 * 1024
    configuration.urlCache = URLCache(memoryCapacity: 2 * MB, diskCapacity: 100 * MB, diskPath: "imageCache")
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration)
}()
