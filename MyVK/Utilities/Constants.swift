//
//  Constants.swift
//  MyVK
//
//  Created by pgc6240 on 15.01.2021.
//

import UIKit

enum C { // Constants
    static let APP_ID = "7704322"
    /*
     7715455
     7707492
     7704322
     */
}


enum JSON {
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}


enum Screen {
    static let width  = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}
