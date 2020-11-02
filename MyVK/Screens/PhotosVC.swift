//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

class PhotosVC: UICollectionViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    
    override var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let columns = sectionIndex.isEven ? 3 : 2
            let spacing: CGFloat = 8
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(spacing)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: spacing)
            return section
        }
        return layout
    }
}


//
// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
//
extension PhotosVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        12
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        return cell
    }
}
