//
//  URLBuilder.swift
//  MyVK
//
//  Created by pgc6240 on 16.01.2021.
//

import Foundation

typealias VKApiMethod = URLBuilder.VKApiMethod

enum URLBuilder {
    
    private static let baseURL  = "https://api.vk.com"
    
    enum VKApiMethod: String {
        var path: String        { "/method/" + rawValue }
        
        case getUsers           = "users.get"
        case getFriends         = "friends.get"
        case getGroups          = "groups.get"
        case getPhotos          = "photos.get"
        case getPosts           = "wall.get"
        case getNewsfeed        = "newsfeed.get"
        case wallPost           = "wall.post"
        case searchGroups       = "groups.search"
        case joinGroup          = "groups.join"
        case leaveGroup         = "groups.leave"
        case like               = "likes.add"
        case dislike            = "likes.delete"
    }
    
    
    static func buildURL(_ apiMethod: VKApiMethod, with parameters: [String: String?]) -> URL? {
        var components          = URLComponents(string: baseURL)
        let parameters          = ["access_token": SessionManager.token, "v": "5.126"] + parameters
        components?.path        = apiMethod.path
        components?.queryItems  = parameters.map { URLQueryItem(name: $0, value: $1) }
        return components?.url
    }
}
