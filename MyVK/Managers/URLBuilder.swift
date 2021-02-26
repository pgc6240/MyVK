//
//  URLBuilder.swift
//  MyVK
//
//  Created by pgc6240 on 16.01.2021.
//

import Alamofire
import Foundation

enum VKApiMethod: String, URLConvertible {
    
    var baseURL: String     { "https://api.vk.com" }
    var path: String        { "/method/" + rawValue }
    
    case getUsers           = "users.get"
    case getFriends         = "friends.get"
    case getGroups          = "groups.get"
    case getPhotos          = "photos.getAll"
    case getPosts           = "wall.get"
    case getNewsfeed        = "newsfeed.getRecommended"
    case wallPost           = "wall.post"
    case deletePost         = "wall.delete"
    case searchGroups       = "groups.search"
    case joinGroup          = "groups.join"
    case leaveGroup         = "groups.leave"
    case getMembers         = "groups.getMembers"
    case getGroupsById      = "groups.getById"
    case like               = "likes.add"
    case dislike            = "likes.delete"
    case searchUsers        = "users.search"
    case addFriend          = "friends.add"
    
    var parameters: [String: String?] {
        switch self {
        case .getUsers:         return ["fields": """
                                                    photo_max,first_name_gen,last_name_gen,home_town,bdate,
                                                    is_closed,counters,can_send_friend_request,friend_status
                                        """]
        case .getFriends:       return Self.getUsers.parameters
        case .getGroups:        return ["extended": "1", "fields": "city,counters,members_count"]
        case .getGroupsById:    return ["extended": "1", "fields": "city,counters,members_count"]
        case .getPhotos:        return ["album_id": "profile"]
        case .getNewsfeed:      return ["filters": "post,photo,wall_photo",
                                        "fields": "photo_max,first_name_gen,last_name_gen,home_town,bdate,is_closed,city"]
        case .searchUsers:      return Self.getUsers.parameters
        case .searchGroups:     return Self.getGroups.parameters
        default:                return [:]
        }
    }
    
    
    func asURL() throws -> URL {
        var components          = URLComponents(string: baseURL)
        let parameters          = ["access_token": SessionManager.token, "v": "5.126"] + self.parameters
        components?.path        = self.path
        components?.queryItems  = parameters.map { URLQueryItem(name: $0, value: $1) }
        guard let url = components?.url else { throw AFError.invalidURL(url: self) }
        return url
    }
}
