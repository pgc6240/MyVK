//
//  ViewController.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        logoImageView.layer.cornerRadius = 15
    }
}

