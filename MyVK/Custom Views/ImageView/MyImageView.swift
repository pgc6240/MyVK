//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

private let session: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.waitsForConnectivity = true
    configuration.requestCachePolicy = .returnCacheDataElseLoad
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
