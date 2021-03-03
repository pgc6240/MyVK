//
//  PostCellDelegate.swift
//  MyVK
//
//  Created by pgc6240 on 26.02.2021.
//

protocol PostCellDelegate: class {
    func deletePost(postId: Int)
    func profileTapped(on post: Post)
    func photoTapped(on post: Post)
    func showMoreText(at row: Int)
}

extension PostCellDelegate {
    func deletePost(postId: Int) {}
    func profileTapped(on post: Post) {}
}
