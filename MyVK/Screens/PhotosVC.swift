//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

class PhotosVC: UICollectionViewController {

    var friend: Friend?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        title = "Фотографии \(friend?.firstName ?? "") \(friend?.lastName ?? "")"
    }
}


//
// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
//
extension PhotosVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        return cell
    }
}
