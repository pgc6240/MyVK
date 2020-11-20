//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class Photo {
    
    var image: UIImage?
    
    
    init(imageName: String) {
        image = UIImage(named: imageName)
    }
}
