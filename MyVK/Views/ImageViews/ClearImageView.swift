//
//  ClearImageView.swift
//  MyVK
//
//  Created by pgc6240 on 23.02.2021.
//

import UIKit

final class ClearImageView: UIImageView, URLDownloadableImage {
    
    var downloadURLString: String?
    weak var downloadImageOperation: DownloadImageOperation?
}
