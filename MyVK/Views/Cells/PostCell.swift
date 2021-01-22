//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    @IBOutlet weak var postTextLabel: UILabel!
    
    
    func set(with post: Post) {
        postTextLabel.text = post.text
    }
}
