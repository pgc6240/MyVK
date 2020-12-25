//
//  MyImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

final class MyImageView: UIImageView {

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()
    
    private var task: URLSessionDataTask?
    
    
    func prepareForReuse() {
        task?.cancel()
        image = nil
    }
    
    
    func downloadImage(url: String?) {
        guard let string = url, let url = URL(string: string) else { return }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        
        task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        task?.resume()
    }
}
