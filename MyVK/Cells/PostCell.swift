//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    static let reuseId = String(describing: PostCell.self)
    
    
    func set(with post: Post) {
        textLabel?.text = post.text
    }
}
