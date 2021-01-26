//
//  Constants.swift
//  MyVK
//
//  Created by pgc6240 on 15.01.2021.
//

import UIKit

enum C { // Constants
    static let APP_IDS = ["7715455", "7707492" ,"7704322", "7732001", "7732004"]
}


enum JSON {
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}


enum Screen {
    static let bounds = UIScreen.main.bounds
    static let width  = bounds.width
    static let height = bounds.height
}
