//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 20.11.2020.
//

import UIKit

final class PhotosVC: UICollectionViewController {
    
    var user: User!
    var photos: [Photo] = []
    
    private var currentPage = 0 { didSet { updateTitle() }}
    
    private var interactiveTransition = _InteractiveTransition()
    
    lazy private var swipeGesture: UIPanGestureRecognizer = {
        let recognizer      = UIPanGestureRecognizer(target: self, action: #selector(swipeRightToPop(_:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        configureCollectionView()
        getPhotos()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrideUserInterfaceStyle                    = .unspecified
        navigationController?.navigationBar.barStyle  = .default
        tabBarController?.overrideUserInterfaceStyle  = .unspecified
        (parent as? UINavigationController)?.setNavigationBarHidden(true, animated: false)
    }
    
    
    private func configureViewController() {
        title                                         = "..."
        view.backgroundColor                          = .black
        overrideUserInterfaceStyle                    = .dark
        navigationController?.navigationBar.barStyle  = .black
        tabBarController?.overrideUserInterfaceStyle  = .dark
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    private func configureCollectionView() {
        collectionView.backgroundColor                = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.addGestureRecognizer(swipeGesture)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width: Screen.width, height: Screen.height)
            layout.scrollDirection          = .horizontal
            layout.minimumLineSpacing       = 0
            layout.minimumInteritemSpacing  = 0
        }
    }
    
    
    func getPhotos() {
        NetworkManager.shared.getPhotos(for: user.id) { [weak self] photos in
            if photos.isEmpty {
                self?.title = "Нет фотографий".localized
                return
            }
            
            self?.updatePhotos(with: photos)
        }
    }
    
    
    private func updatePhotos(with newPhotos: [Photo]) {
        photos = newPhotos
        collectionView.reloadData()
        updateTitle()
        photos.forEach { $0.owner = user }
        PersistenceManager.save(photos)
    }
    
    
    private func updateTitle() {
        guard !photos.isEmpty else { return }
        title = "Фотография ".localized + String(currentPage + 1) + " из ".localized + String(photos.count)
    }
}


//
// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
//
extension PhotosVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.set(with: photo)
        return cell
    }
}


//
// MARK: - UIScrollViewDelegate
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
// MARK: - UIGestureRecognizerDelegate
//
extension PhotosVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        currentPage == 0
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    
    @objc func swipeRightToPop(_ recognizer: UIPanGestureRecognizer) {
        let translationX         = recognizer.translation(in: view).x
        let navigationController = self.navigationController as? _NavigationController
        
        guard translationX > 0 else { return }
        
        switch recognizer.state {
        case .began:
            interactiveTransition.hasBegan = true
            navigationController?.interactiveTransition = interactiveTransition
            navigationController?.popViewController(animated: true)
        
        case .changed:
            let relativeTranslation = translationX / Screen.width
            interactiveTransition.shouldFinishTransition = relativeTranslation > 0.33
            interactiveTransition.update(relativeTranslation)
            
        case .ended:
            interactiveTransition.hasBegan = false
            interactiveTransition.shouldFinishTransition ? interactiveTransition.finish() : interactiveTransition.cancel()
            
        case .cancelled:
            interactiveTransition.hasBegan = false
            interactiveTransition.cancel()
        
        default:
            return
        }
    }
}
