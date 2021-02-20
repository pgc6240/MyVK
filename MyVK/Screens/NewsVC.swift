//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 07.02.2021.
//

import UIKit

final class NewsVC: UITableViewController {
    
    var posts: [Post] = []
    
    // MARK: - Internal properties
    private var nextFrom: String?
    private var currentPage = 0
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private weak var selectedPost: Post!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if posts.isEmpty {
            showLoadingView()
            getNewsfeed()
        } else {
            updateUI()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        queue.cancelAllOperations()
    }
    
    
    // MARK: - External methods -
    func getNewsfeed() {
        let operation = GetNewsfeedOperation(startFrom: nextFrom)
        operation.completionBlock = { [weak self] in
            DispatchQueue.main.async { self?.dismissLoadingView() }
            self?.nextFrom = operation.nextFrom
            self?.updateNewsfeed(with: operation.posts)
        }
        queue.addOperation(operation)
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
    
    private func updateNewsfeed(with newPosts: [Post]?) {
        guard let newPosts = newPosts else { return }
        let indexPaths = (posts.count..<(posts.count + newPosts.count)).map { IndexPath(row: $0, section: 0) }
        posts.append(contentsOf: newPosts)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.insertRows(at: indexPaths, with: .bottom)
        }
    }
    
    
    // MARK: - Segues -
    private enum SegueIdentifier: String {
        case fromPostToProfile
        case fromPostToPhotos
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }
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
        posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post)
        cell.delegate = self
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//
// MARK: - UIScrollViewDelegate
//
extension NewsVC {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let cell = tableView.visibleCells.first, let indexPath = tableView.indexPath(for: cell) else { return }
        
        if ((currentPage * 50)..<posts.count).contains(indexPath.row) {
            currentPage = posts.count / 50
            getNewsfeed()
        }
    }
}


//
// MARK: - PostCellDelegate
//
extension NewsVC: PostCellDelegate {
    
    func profileTapped(on post: Post) {
        selectedPost = post
        performSegue(withIdentifier: SegueIdentifier.fromPostToProfile.rawValue, sender: nil)
    }
    
    
    func photoTapped(on post: Post) {
        selectedPost = post
        performSegue(withIdentifier: SegueIdentifier.fromPostToPhotos.rawValue, sender: nil)
    }
}
