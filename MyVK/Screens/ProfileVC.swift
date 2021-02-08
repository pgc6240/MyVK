//
//  ProfileVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class ProfileVC: UIViewController, PostCellDelegate {
    
    private lazy var postsVC = children.first as? PostsVC
    
    
    // MARK: - External methods -
    func wallPost(message: String?) {
        guard let message = message else { return }
        
        showLoadingView()
        NetworkManager.shared.wallPost(message: message) { [weak self] postId in
            self?.dismissLoadingView()
            
            if postId != nil {
                self?.postsVC?.getPosts()
            }
        }
    }
    
    
    func deletePost(postId: Int) {
        let alertTitle   = "Вы точно хотите удалить запись?".localized
        let alertMessage = "Это действие будет невозможно отменить.".localized
        let alertSheet   = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        let cancel       = UIAlertAction(title: "Нет".localized, style: .default)
        let deletePost   = UIAlertAction(title: "Да".localized, style: .destructive) { [postId] _ in
            NetworkManager.shared.deletePost(postId: postId) { [weak self] isSuccessful in
                guard isSuccessful else { return }
                self?.postsVC?.getPosts()
            }
        }
        alertSheet.addAction(cancel)
        alertSheet.addAction(deletePost)
        alertSheet.view.tintColor = UIColor.vkColor
        present(alertSheet, animated: true)
    }
    
    
    // MARK: - Navigation bar button methods -
    @IBAction private func postButtonTapped() {
        let alert = makeAlert(title: "Новая запись на стене:", cancelTitle: "Закрыть")
        let wallPost = UIAlertAction(title: "Отправить".localized, style: .destructive) { [weak self] _ in
            self?.wallPost(message: alert.textFields?.first?.text)
        }
        alert.addTextField { $0.placeholder = "Текст новой записи".localized }
        alert.addAction(wallPost)
        present(alert, animated: true)
    }
    
    @IBAction private func logoutButtonTapped() {
        SessionManager.logout()
    }
}
