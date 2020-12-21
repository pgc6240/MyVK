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
        case getFriends    = "/method/friends.get"
        case getGroups     = "/method/groups.get"
        case getPhotos     = "/method/photos.get"
        case searchGroups  = "/method/groups.search"
        
        var path: String   { rawValue }
    }
    
    
    private func makeURL(method: Method, parameters input: [String: String?]) -> URL? {
        var components         = URLComponents(string: baseURL)
        let parameters         = ["access_token": SessionManager.token, "v": apiVersion] + input
        components?.path       = method.path
        components?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return components?.url
    }
    
    
    private func makeRequest<I: Decodable>(_ url: URL, responseItem: I.Type, completion: @escaping ([I]) -> Void) {
        let decoder                 = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        AF.request(url).responseDecodable(of: Response<I>.self, decoder: decoder) {
            switch $0.result {
            case .success(let data):
                completion(data.response.items)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func getFriends(friends: @escaping ([User]) -> Void) {
        guard let url = makeURL(method: .getFriends, parameters: ["fields": "bdate"]) else { return }
        makeRequest(url, responseItem: User.self) { friends($0) }
    }
    
    
    func getGroups(groups: @escaping ([Group]) -> Void) {
        guard let url = makeURL(method: .getGroups, parameters: ["extended": "1"]) else { return }
        makeRequest(url, responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int?) {
        let parameters = ["owner_id": String(userId), "album_id": "profile"]
        guard let url = makeURL(method: .getPhotos, parameters: parameters) else { return }
        print(url)
    }
    
    
    func searchGroups(_ searchQuery: String?, searchResults: @escaping ([Group]) -> Void) {
        guard let url = makeURL(method: .searchGroups, parameters: ["q": searchQuery]) else { return }
        makeRequest(url, responseItem: Group.self) { searchResults($0) }
    }
}


//
// MARK: - Response -
//
fileprivate struct Response<I: Decodable>: Decodable {
    var response: Items<I>
    
    struct Items<I: Decodable>: Decodable {
        var count: Int
        var items: [I]
    }
}
