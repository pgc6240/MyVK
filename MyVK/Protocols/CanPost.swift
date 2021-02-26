//
//  CanPost.swift
//  MyVK
//
//  Created by pgc6240 on 16.02.2021.
//

import RealmSwift

protocol CanPost: class {
    var id: Int { get }
    var name: String { get }
    var photoUrl: String { get }
    var postsCount: Int { get set }
    var posts: List<Post> { get }
    var photos: List<Photo> { get }
    var secondaryText: String? { get }
}
