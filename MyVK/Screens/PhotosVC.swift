//
//  PhotosVC.swift
//  MyVK
//
//  Created by pgc6240 on 20.11.2020.
//

import UIKit

final class PhotosVC: UICollectionViewController {
    
    var photos: [Photo] = []
    
    private let pageWidth   = UIScreen.main.bounds.width
    private var currentPage = 0 { didSet { updateUI() }}
    
    private var userInterfaceStyle: UIUserInterfaceStyle!
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    private var interactiveTransition  = _InteractiveTransition()
    private var shouldFinishTransition = false
    
    
    init(_ photos: [Photo] = []) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.photos = photos
        self.userInterfaceStyle = traitCollection.userInterfaceStyle
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.userInterfaceStyle = traitCollection.userInterfaceStyle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        overrideUserInterfaceStyle                    = userInterfaceStyle
        navigationController?.navigationBar.barStyle  = .default
        tabBarController?.overrideUserInterfaceStyle  = userInterfaceStyle
    }
    
    
    private func configureViewController() {
        view.backgroundColor                          = .black
        overrideUserInterfaceStyle                    = .dark
        navigationController?.navigationBar.barStyle  = .black
        tabBarController?.overrideUserInterfaceStyle  = .dark
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width: pageWidth, height: pageWidth)
            layout.scrollDirection          = .horizontal
            layout.minimumLineSpacing       = 0
            layout.minimumInteritemSpacing  = 0
        }
    }
    
    
    private func updateUI() {
        title = photos.isEmpty ? "Нет фотографий" : "Фотография \(currentPage + 1) из \(photos.count)"
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
        let relativeOffset      = currentOffset.truncatingRemainder(dividingBy: pageWidth) / pageWidth
        currentPage             = Int((currentOffset + pageWidth / 2) / pageWidth)
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
    
    
    @IBAction func swipeRightToPop(_ recognizer: UIPanGestureRecognizer) {
        let translationX         = recognizer.translation(in: view).x
        let navigationController = self.navigationController as? _NavigationController
        
        switch recognizer.state {
        case .began:
            interactiveTransition.hasBegan = true
            navigationController?.interactiveTransition = interactiveTransition
            navigationController?.popViewController(animated: true)
        
        case .changed:
            let relativeTranslation = translationX / pageWidth
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
