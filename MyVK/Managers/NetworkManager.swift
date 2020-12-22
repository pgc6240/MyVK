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
    
    private enum APIMethod: String {
        var path: String   { "/method/" + rawValue }
        
        case getFriends    = "friends.get"
        case getGroups     = "groups.get"
        case getPhotos     = "photos.get"
        case searchGroups  = "groups.search"
        case joinGroup     = "groups.join"
        case leaveGroup    = "groups.leave"
    }
    
    
    private func makeURL(apiMethod: APIMethod, parameters input: [String: String?]) -> URL? {
        var components         = URLComponents(string: baseURL)
        let parameters         = ["access_token": SessionManager.token, "v": apiVersion] + input
        components?.path       = apiMethod.path
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
    
    
    private func makeRequest(_ url: URL, completed: @escaping (Bool) -> Void) {
        AF.request(url).responseJSON {
            if let value = $0.value as? [String: Int], value["response"] == 1 {
                completed(true)
            } else {
                completed(false)
            }
        }
    }
    
    
    func getFriends(friends: @escaping ([User]) -> Void) {
        guard let url = makeURL(apiMethod: .getFriends, parameters: ["fields": "bdate"]) else { return }
        makeRequest(url, responseItem: User.self) { friends($0) }
    }
    
    
    func getGroups(groups: @escaping ([Group]) -> Void) {
        guard let url = makeURL(apiMethod: .getGroups, parameters: ["extended": "1"]) else { return }
        makeRequest(url, responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int, photos: @escaping ([Photo]) -> Void) {
        let parameters = ["owner_id": String(userId), "album_id": "profile"]
        guard let url = makeURL(apiMethod: .getPhotos, parameters: parameters) else { return }
        makeRequest(url, responseItem: Photo.self) { photos($0) }
    }
    
    
    func searchGroups(_ searchQuery: String?, searchResults: @escaping ([Group]) -> Void) {
        guard let url = makeURL(apiMethod: .searchGroups, parameters: ["q": searchQuery]) else { return }
        makeRequest(url, responseItem: Group.self) { searchResults($0) }
    }
    
    
    func joinGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        guard let url = makeURL(apiMethod: .joinGroup, parameters: ["group_id": String(groupId)]) else { return }
        makeRequest(url, completed: isSuccessful)
    }
    
    
    func leaveGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        guard let url = makeURL(apiMethod: .leaveGroup, parameters: ["group_id": String(groupId)]) else { return }
        makeRequest(url, completed: isSuccessful)
    }
    
    
    func downloadPhoto(url: String?, photo: @escaping (UIImage?) -> Void) {
        guard let url = url else { return }
        AF.request(url).responseData {
            guard let data = $0.data else {
                photo(nil)
                return
            }
            let image = UIImage(data: data)
            photo(image)
        }
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
