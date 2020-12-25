//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

fileprivate let session: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    let MB = 1024 * 1024
    configuration.urlCache = URLCache(memoryCapacity: 2 * MB, diskCapacity: 100 * MB, diskPath: "imageCache")
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration)
}()

final class MyImageView: UIImageView {
    
    private weak var task: URLSessionDataTask?
    
    func downloadImage(url: String) {
        guard let url = URL(string: url) else { return }
        task = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { self?.image = UIImage(data: data) }
        }
        task?.resume()
    }
    
    func prepareForReuse() {
        task?.cancel()
        image = nil
    }
}
