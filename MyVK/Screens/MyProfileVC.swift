//
//  MyProfileVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class MyProfileVC: ProfileVC, PostCellDelegate {
    
    
    // MARK: - External methods -
    func wallPost(message: String?) {
        guard let message = message else { return }
        showLoadingView()
        NetworkManager.shared.wallPost(message: message) { [weak self] postId in
            self?.dismissLoadingView()
            if postId != nil {
                self?.postsVC.getPosts()
            }
        }
    }
    
    
    func deletePost(postId: Int) {
        let alertTitle   = "Вы точно хотите удалить запись?"
        let alertMessage = "Это действие будет невозможно отменить."
        let cancel       = UIAlertAction(title: "Нет".localized, style: .default)
        let deletePost   = UIAlertAction(title: "Да".localized, style: .destructive) { [postId] _ in
            NetworkManager.shared.deletePost(postId: postId) { [weak self] isSuccessful in
                guard isSuccessful else { return }
                self?.postsVC.getPosts()
            }
        }
        presentActionSheet(title: alertTitle, message: alertMessage, actions: [cancel, deletePost])
    }
    
    
    // MARK: - Navigation bar button methods -
    @IBAction private func postButtonTapped() {
        let alert    = makeAlert(title: "Новая запись на стене:", cancelTitle: "Закрыть")
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
    
    
    // MARK: - Profile header buttons methods -
    @IBAction private func friendsButtonTapped() {
        tabBarController?.selectedIndex = 1
    }
    
    
    @IBAction private func groupsButtonTapped() {
        tabBarController?.selectedIndex = 2
    }
    
    
    // MARK: - Prepare for segue to PhotosVC -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? PhotosVC)?.owner = User.current
    }
    
    
    override func prepareFriendsVC(for user: User) {}
}
