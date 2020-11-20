//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 20.11.2020.
//

import UIKit

final class PhotosVC: UICollectionViewController {
    
    var photos: [Photo] = []
    
    private var userInterfaceStyle: UIUserInterfaceStyle!
    
    
    init(_ photos: [Photo] = []) {
        super.init(collectionViewLayout: PhotosLayout())
        self.photos = photos
        self.userInterfaceStyle = traitCollection.userInterfaceStyle
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.userInterfaceStyle = traitCollection.userInterfaceStyle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.setAnimationsEnabled(false)
        overrideUserInterfaceStyle = userInterfaceStyle
        navigationController?.navigationBar.barStyle = .default
        tabBarController?.overrideUserInterfaceStyle = userInterfaceStyle
    }
    
    
    private func configureViewController() {
        view.backgroundColor = .black
        overrideUserInterfaceStyle = .dark
        navigationController?.navigationBar.barStyle = .black
        tabBarController?.overrideUserInterfaceStyle = .dark
        setNeedsStatusBarAppearanceUpdate()
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .black
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        collectionView.contentSize.width = CGFloat(photos.count) * UIScreen.main.bounds.width
        
    }
}


//
//
//
extension PhotosVC: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.set(with: photo)
        return cell
    }
}


final class PhotosLayout: UICollectionViewFlowLayout {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        scrollDirection = .horizontal
    }
}
