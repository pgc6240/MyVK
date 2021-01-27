//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit
import RealmSwift

final class NewsVC: UIViewController {
    
    var token: NotificationToken?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
    }
    
    
    private func setTitle() {
        navigationItem.title = User.current.name
        token = User.current.observe { [weak self] _ in
            self?.navigationItem.title = User.current.name
        }
    }
    
    
    @IBAction func postButtonTapped() {
        let alert = makeAlert(title: "Новая запись на стене:", cancelTitle: "Закрыть")
        alert.addTextField { $0.placeholder = "Текст новой записи".localized }
        alert.addAction(UIAlertAction(title: "Отправить".localized, style: .destructive) { _ in
            guard let message = alert.textFields?.first?.text, !message.isEmpty else { return }
            NetworkManager.shared.wallPost(message: message) { [weak self] postId in
                guard postId != nil else { return }
                (self?.children.first as? PostsVC)?.getPosts()
            }
        })
        alert.view.tintColor = UIColor.vkColor
        present(alert, animated: true)
    }
    
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
}
