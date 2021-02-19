//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 20.11.2020.
//

import UIKit
import RealmSwift

final class PhotosVC: UICollectionViewController {
    
    var owner: CanPost?
    var post: Post?
    lazy var photos = owner?.photos ?? post?.photos
    
    private var token: NotificationToken?
    
    private var currentPage = 0 { didSet { updateTitle() }}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        startObservingPhotos()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController()
        getPhotos()
    }
    
    
    private func configureCollectionView() {
        collectionView.backgroundColor                = .black
        collectionView.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width: Screen.width, height: Screen.height)
            layout.scrollDirection          = .horizontal
            layout.minimumLineSpacing       = 0
            layout.minimumInteritemSpacing  = 0
        }
    }
    
    
    private func startObservingPhotos() {
        token = photos?.observe { [weak self] changes in
            self?.updateTitle()
            self?.collectionView.reloadData()
        }
    }
    
    
    func getPhotos() {
        guard let owner = owner else { return }
        showLoadingView()
        let ownerId = owner is Group ? -owner.id : owner.id
        NetworkManager.shared.getPhotos(for: ownerId) { [weak self] photos in
            self?.dismissLoadingView()
            self?.updateTitle()
            PersistenceManager.save(photos, in: self?.owner?.photos)
        }
    }
    
    
    private func updateTitle() {
        if isLoading && photos?.count ?? 0 == 0 {
            title = "..."
        } else if photos?.count ?? 0 == 0 {
            title = "Нет фотографий".localized
        } else {
            title = "Фотография ".localized + String(currentPage + 1) + " из ".localized + String(photos?.count ?? 0)
        }
    }
}


//
// MARK: - UICollectionViewDataSource & UICollectionViewDelegate -
//
extension PhotosVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos?.count ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        if let photo = photos?[indexPath.row] {
            cell.set(with: photo)
        }
        return cell
    }
}


//
// MARK: - UIScrollViewDelegate (swipe photos functionality) -
//
extension PhotosVC {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset       = scrollView.contentOffset.x
        let relativeOffset      = currentOffset.truncatingRemainder(dividingBy: Screen.width) / Screen.width
        currentPage             = Int((currentOffset + Screen.width / 2) / Screen.width)
        let selectedCellIndex   = collectionView.indexPathForItem(at: CGPoint(x: currentOffset, y: view.frame.midY))
        let selectedCell        = collectionView.cellForItem(at: selectedCellIndex ?? [0,0])
        let scaleFactor         = 1 - relativeOffset * 0.5
        selectedCell?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    }
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        collectionView.scrollToItem(at: [0, currentPage], at: .centeredHorizontally, animated: true)
    }
    
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        collectionView.scrollToItem(at: [0, currentPage], at: .centeredHorizontally, animated: true)
    }
}


//
// MARK: - Animation-related stuff (going to dark mode on appear and vice versa) -
//
extension PhotosVC {
    
    private func configureViewController() {
        title                                         = ""
        view.backgroundColor                          = .black
        overrideUserInterfaceStyle                    = .dark
        navigationController?.navigationBar.barStyle  = .black
        tabBarController?.overrideUserInterfaceStyle  = .dark
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrideUserInterfaceStyle                    = .unspecified
        navigationController?.navigationBar.barStyle  = .default
        tabBarController?.overrideUserInterfaceStyle  = .unspecified
        (parent as? UINavigationController)?.setNavigationBarHidden(true, animated: false)
    }
}
