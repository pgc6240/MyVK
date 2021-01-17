//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

final class MyImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { layer.cornerRadius = newValue }
    }
    
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
