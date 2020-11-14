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
    @IBOutlet weak var postActionsStackView: UIStackView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let likeButton = LikeButton(likeCount: 50)
        postActionsStackView.insertArrangedSubview(likeButton, at: 0)
    }
}
