//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    
    private enum Method: String {
        case getFriends = "/method/friends.get"
        case getGroups  = "/method/groups.get"
        case getPhotos  = "/method/photos.get"
    }
    
    
    private func makeURL(method: Method, parameters input: [String: String?]) -> URL? {
        var urlComponents = URLComponents(string: "https://api.vk.com")
        urlComponents?.path = method.rawValue
        var parameters = ["access_token" : Session.shared.token, "v" : "5.126"]
        input.forEach { parameters[$0] = $1 }
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents?.url
    }
    
    
    func getFriends() {
        guard let url = makeURL(method: .getFriends, parameters: ["fields": "bdate"]) else { return }
        AF.request(url).responseDecodable(of: Response<User>.self, decoder: decoder) { response in
            let friends = response.value?.response.items
            friends?.forEach { print($0.firstName, $0.lastName) }
        }
    }
    
    
    func getGroups() {
        guard let url = makeURL(method: .getGroups, parameters: ["extended":"1"]) else { return }
        AF.request(url).responseDecodable(of: Response<Group>.self, decoder: decoder) { response in
            let groups = response.value?.response.items
            groups?.forEach { print($0.name) }
        }
    }
    
    
    func getPhotos() {
        guard let url = makeURL(method: .getPhotos, parameters: ["album_id":"profile"]) else { return }
        print(url)
    }
}
