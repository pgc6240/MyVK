//
//  AnimationsVC.swift
//  MyVK
//
//  Created by pgc6240 on 18.11.2020.
//

import UIKit

final class AnimationsVC: UIViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showLoadingView(duration: .infinity)
    }
}
