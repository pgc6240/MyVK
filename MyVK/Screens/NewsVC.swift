//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 07.02.2021.
//

import UIKit

final class NewsVC: UITableViewController {
    
    var posts = [Post]()
    
    // MARK: - Internal properties
    private var nextFrom: String?
    private weak var selectedPost: Post?
    private var textCroppedAtIndexPath = [IndexPath: Bool]()
    private let queue: OperationQueue  = {
        let queue                         = OperationQueue()
        queue.qualityOfService            = .userInteractive
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
        configureRefreshControl()
        refreshNewsfeed()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateUI()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        queue.cancelAllOperations()
    }
    
    
    // MARK: - External methods -
    @objc func refreshNewsfeed() {
        posts = []
        nextFrom = nil
        selectedPost = nil
        textCroppedAtIndexPath = [:]
        queue.cancelAllOperations()
        refreshControl?.beginRefreshing()
        tableView.reloadData()
        getNewsfeed()
    }
    
    
    func getNewsfeed() {
        let operation = GetNewsfeedOperation(startFrom: nextFrom)
        operation.completionBlock = { [weak self] in
            self?.nextFrom = operation.nextFrom
            self?.updateNewsfeed(with: operation.posts)
        }
        guard queue.operations.isEmpty else { return }
        queue.addOperation(operation)
    }
    
    
    // MARK: - Internal methods -
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        let font = UIFont.preferredFont(forTextStyle: .body)
        refreshControl.attributedTitle = NSAttributedString(string: "Загрузка...".localized, attributes: [.font: font])
        refreshControl.addTarget(self, action: #selector(refreshNewsfeed), for: .valueChanged)
        refreshControl.tintColor = .label
        self.refreshControl = refreshControl
    }
    
    
    private func updateNewsfeed(with newPosts: [Post]?) {
        guard let newPosts = newPosts else { return }
        let indexPaths = (posts.count..<(posts.count + newPosts.count)).map { IndexPath(row: $0, section: 0) }
        posts.append(contentsOf: newPosts)
        DispatchQueue.main.async { [weak self] in
            if (self?.refreshControl?.isRefreshing ?? false) {
                self?.refreshControl?.endRefreshing()
            }
            self?.tableView.insertRows(at: indexPaths, with: .bottom)
        }
    }
    
    
    private func updateUI() {
        for cell in tableView.visibleCells {
            guard let cell = cell as? PostCell else { continue }
            cell.reloadImages()
        }
    }
    
    
    // MARK: - Segues -
    private enum SegueIdentifier: String {
        case fromPostToProfile
        case fromPostToPhotos
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier ?? ""),
              let selectedPost    = selectedPost else { return }
        switch segueIdentifier {
        case .fromPostToPhotos: (segue.destination as? PhotosVC)?.post = PersistenceManager.create(selectedPost)
        case .fromPostToProfile:
            if let userOwner = selectedPost.userOwner, let owner = PersistenceManager.create(userOwner) {
                (segue.destination as? ProfileVC)?.owner = owner
            } else if let groupOwner = selectedPost.groupOwner, let owner = PersistenceManager.create(groupOwner) {
                (segue.destination as? ProfileVC)?.owner = owner
            }
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate -
//
extension NewsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.tag = indexPath.row
        cell.delegate = self
        cell.set(with: post, textCropped: &textCroppedAtIndexPath[indexPath])
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if let photo = post.photos.first, let postText = post.text {
            let cellWidth   = tableView.bounds.width
            let photoHeight = cellWidth * photo.aspectRatio
            let textHeight  = (textCroppedAtIndexPath[indexPath] ?? true) ? 200 : postText.size(in: cellWidth).height
            return 60 + textHeight + photoHeight + 35
        }
        return UITableView.automaticDimension
    }
}


//
// MARK: - UITableViewDataSourcePrefetching -
//
extension NewsVC: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxRow = indexPaths.max()?.row else { return }
        if maxRow > posts.count / 2 {
            getNewsfeed()
        }
    }
}


//
// MARK: - PostCellDelegate
//
extension NewsVC: PostCellDelegate {
    
    func showMoreText(at row: Int) {
        textCroppedAtIndexPath[[0, row]]?.toggle()
        tableView.reloadData(animated: true)
    }
    
    
    func profileTapped(on post: Post) {
        selectedPost = post
        performSegue(withIdentifier: SegueIdentifier.fromPostToProfile.rawValue, sender: nil)
    }
    
    
    func photoTapped(on post: Post) {
        selectedPost = post
        performSegue(withIdentifier: SegueIdentifier.fromPostToPhotos.rawValue, sender: nil)
    }
}
