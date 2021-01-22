//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    func set(with post: Post) {
        textLabel?.text = post.text
    }
}
