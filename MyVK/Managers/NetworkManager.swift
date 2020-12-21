//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL    = "https://api.vk.com"
    private let apiVersion = "5.126"
    
    private enum Method: String {
        case getFriends     = "/method/friends.get"
        case getGroups      = "/method/groups.get"
        case getPhotos      = "/method/photos.get"
        case searchGroups   = "/method/groups.search"
        
        var path: String { rawValue }
    }
    
    private let decoder: JSONDecoder = {
        let decoder                 = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    
    private func makeUrl(method: Method, parameters input: [String: String?]) -> URL? {
        var components         = URLComponents(string: baseURL)
        let parameters         = ["access_token" : SessionManager.token, "v" : apiVersion] + input
        components?.path       = method.path
        components?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return components?.url
    }
    
    
    func getFriends() {
        guard let url = makeUrl(method: .getFriends, parameters: ["fields": "bdate"]) else { return }
        AF.request(url).responseDecodable(of: Response<User>.self, decoder: decoder) { response in
            let friends = response.value?.response.items
            #if DEBUG
            print(response.metrics?.taskInterval.duration ?? 0, url.absoluteString)
            friends?.forEach { print($0.firstName, $0.lastName) }
            #endif
        }
    }
    
    
    func getGroups() {
        guard let url = makeUrl(method: .getGroups, parameters: ["extended": "1"]) else { return }
        AF.request(url).responseDecodable(of: Response<Group>.self, decoder: decoder) { response in
            let groups = response.value?.response.items
            #if DEBUG
            print(response.metrics?.taskInterval.duration ?? 0, url.absoluteString)
            groups?.forEach { print($0.name) }
            #endif
        }
    }
    
    
    func getPhotos(for userId: Int) {
        let parameters = [
            "owner_id": String(userId == 0 ? SessionManager.userId! : userId), // это временно
            "album_id": "profile"
        ]
        guard let url = makeUrl(method: .getPhotos, parameters: parameters) else { return }
        #if DEBUG
        print(url.absoluteString)
        #endif
    }
    
    
    func searchGroups(_ searchQuery: String?) {
        guard let url = makeUrl(method: .searchGroups, parameters: ["q": searchQuery]) else { return }
        AF.request(url).responseDecodable(of: Response<Group>.self, decoder: decoder) { response in
            let groups = response.value?.response.items
            #if DEBUG
            print(response.metrics?.taskInterval.duration ?? 0, url.absoluteString)
            groups?.forEach { print($0.name) }
            #endif
        }
    }
}
