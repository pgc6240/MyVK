//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class PostCell: UITableViewCell {

    static let reuseId = String(describing: self)
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var likeButton: LikeButton!
    
    
}
