//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

final class PhotosVC: UICollectionViewController {

    var photos: [[Photo]] = [[]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    
    func loadPhotos() {
        photos.remove(at: 0)
        photos.append([somePhotos[0]])
        photos.append(somePhotos)
        photos.append(somePhotos.dropLast())
        photos.append([somePhotos[1]])
        photos.append(somePhotos + [somePhotos[1]])
        photos.append(Array(somePhotos[1...2]))
    }
    
    
    override var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [photos] sectionIndex, layoutEnvironment in
            
            var largePhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.65), heightDimension: .fractionalHeight(1))
            let largePhoto: NSCollectionLayoutItem
            var smallPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            var smallPhoto = NSCollectionLayoutItem(layoutSize: smallPhotoSize)
            var groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
            let group: NSCollectionLayoutGroup
            
            switch photos[sectionIndex].count {
            case 3, 4:
                largePhoto = NSCollectionLayoutItem(layoutSize: largePhotoSize)
                smallPhoto = NSCollectionLayoutItem(layoutSize: smallPhotoSize)
                let smallPhotosGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.35), heightDimension: .fractionalHeight(1))
                let smallPhotosGroup = NSCollectionLayoutGroup.vertical(layoutSize: smallPhotosGroupSize, subitem: smallPhoto, count: photos[sectionIndex].count - 1)
                groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.65))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [largePhoto, smallPhotosGroup])
            case 2:
                largePhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
                largePhoto = NSCollectionLayoutItem(layoutSize: largePhotoSize)
                smallPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
                smallPhoto = NSCollectionLayoutItem(layoutSize: smallPhotoSize)
                groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [largePhoto, smallPhoto])
            default:
                largePhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
                largePhoto = NSCollectionLayoutItem(layoutSize: largePhotoSize)
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [largePhoto])
            }
            
            let section = NSCollectionLayoutSection(group: group)
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
        photos.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos[section].count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.section][indexPath.row]
        cell.set(with: photo)
        return cell
    }
}
