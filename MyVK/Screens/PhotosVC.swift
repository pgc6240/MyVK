//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

final class PhotosVC: UICollectionViewController {

    var photos: [[Photo]] = [[]]
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setPhotos()
    }
    
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: .init())
    }
    
    
    convenience init(photos: [Photo], maxPhotosPerSection: Int) {
        self.init(collectionViewLayout: .init())
        setPhotos(with: photos, maxPhotosPerSection: maxPhotosPerSection)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        collectionView.collectionViewLayout = photosCollectionViewLayout
    }
    
    
    func setPhotos(with photosArray: [Photo] = [], maxPhotosPerSection: Int = 4) {
        photos.remove(at: 0)
        
        if photosArray.isEmpty {
            photos.append(contentsOf: [[somePhotos[0]], somePhotos, somePhotos.dropLast(), [somePhotos[1]], somePhotos + [somePhotos[1]], Array(somePhotos[1...2])])
        
        } else {
            let maxPhotosPerSection = maxPhotosPerSection > 4 ? 4 : maxPhotosPerSection
            for (index, photo) in photosArray.enumerated() {
                if index % maxPhotosPerSection == 0 {
                    photos.append([photo])
                    continue
                }
                photos[photos.endIndex - 1].append(photo)
            }
        }
    }
    
    
    var photosCollectionViewLayout: UICollectionViewLayout {
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
                let largePhotoFirst = Bool.random()
                let groupItems = largePhotoFirst ? [largePhoto, smallPhotosGroup] : [smallPhotosGroup, largePhoto]
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: groupItems)
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
