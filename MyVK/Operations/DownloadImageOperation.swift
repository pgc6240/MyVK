//
//  DownloadImageOperation.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import UIKit

final class DownloadImageOperation: AsyncOperation {
    
    var downloadedImage: UIImage?
    
    private var downloadTask: URLSessionDownloadTask?
    private let downloadURL: URL
    private let dstURL: URL
    
    
    init?(_ downloadURLString: String?) {
        guard let downloadURL     = URL(string: downloadURLString),
              let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        self.downloadURL = downloadURL
        self.dstURL      = cachesDirectory.appendingPathComponent(downloadURL.lastPathComponent)
        super.init()
    }
    
    
    override func main() {
        if let imageCached  = UIImage(contentsOfFile: dstURL.path) {
            downloadedImage = imageCached
            state           = .finished
            return
        }
        
        downloadTask = URLSession.shared.downloadTask(with: downloadURL) { [weak self, dstURL] location, _, _ in
            guard let self = self, let srcURL = location else { return }
            defer { self.state = .finished }
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try? FileManager.default.removeItem(at: dstURL)
            }
            try? FileManager.default.moveItem(at: srcURL, to: dstURL)
            guard !self.isCancelled else { return }
            self.downloadedImage = UIImage(contentsOfFile: dstURL.path)
        }
        
        downloadTask?.resume()
    }
    
    
    override func cancel() {
        downloadTask?.cancel()
        super.cancel()
    }
}