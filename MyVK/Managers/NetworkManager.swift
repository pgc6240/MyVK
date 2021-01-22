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
    
    
    // MARK: - Internal methods -
    private func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                                           parameters: [String: String?],
                                           responseItem: I.Type,
                                           completion: @escaping ([I]) -> Void)
    {
        guard let url = URLBuilder.buildURL(vkApiMethod, with: parameters) else {
            return
        }
        
        AF.request(url).responseDecodable(of: Response<I>.self, decoder: JSON.decoder) {
            switch $0.result {
            case .success(let response):
                completion(response.response.items)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func makeRequest(_ vkApiMethod: VKApiMethod,
                             parameters: [String: String?],
                             isSuccessful: @escaping (Bool) -> Void)
    {
        guard let url = URLBuilder.buildURL(vkApiMethod, with: parameters) else { return }
        
        AF.request(url).responseJSON {
            /* Sample response JSON: { "response": 1 } */
            isSuccessful(($0.value as? [String: Int])?["response"] == 1)
        }
    }
    
    
    // MARK: - External methods -
    func getFriends(friends: @escaping ([User]) -> Void) {
        makeRequest(.getFriends, parameters: ["fields": "photo_max"], responseItem: User.self) { friends($0) }
    }
    
    
    func getGroups(groups: @escaping ([Group]) -> Void) {
        makeRequest(.getGroups, parameters: ["extended": "1"], responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int, photos: @escaping ([Photo]) -> Void) {
        let parameters = ["owner_id": String(userId), "album_id": "profile"]
        makeRequest(.getPhotos, parameters: parameters, responseItem: Photo.self) { photos($0) }
    }
    
    
    func getPosts(ownerId: Int, posts: @escaping ([Post]) -> Void) {
        makeRequest(.getPosts, parameters: ["owner_id": String(ownerId)], responseItem: Post.self) { posts($0) }
    }
    
    
    func searchGroups(_ searchQuery: String?, searchResults: @escaping ([Group]) -> Void) {
        makeRequest(.searchGroups, parameters: ["q": searchQuery], responseItem: Group.self) { searchResults($0) }
    }
    
    
    func joinGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.joinGroup, parameters: ["group_id": String(groupId)], isSuccessful: isSuccessful)
    }
    
    
    func leaveGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.leaveGroup, parameters: ["group_id": String(groupId)], isSuccessful: isSuccessful)
    }
}


//
// MARK: - Response -
//
fileprivate struct Response<I: Decodable>: Decodable {
    let response: Items<I>
    
    struct Items<I: Decodable>: Decodable {
        let items: [I]
    }
}
