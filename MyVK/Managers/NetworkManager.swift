//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Alamofire
import Combine

final class NetworkManager {
    
    // MARK: - Singleton -
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
                if let data = $0.data, let responseError = try? JSON.decoder.decode(ResponseError.self, from: data) {
                    print(responseError.code, responseError.message)
                } else {
                    print(url, error, separator: "\n")
                }
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
    
    
    private func makeRequest(_ vkApiMethod: VKApiMethod,
                             parameters: [String: String?],
                             expecting: String,
                             number: @escaping (Int?) -> Void)
    {
        guard let url = URLBuilder.buildURL(vkApiMethod, with: parameters) else { return }
        
        AF.request(url).responseJSON {
            /* Sample response JSON: { "response": { "likes": 12 } } */
            number((($0.value as? [String: Any])?["response"] as? [String: Int])?[expecting])
        }
    }
    
    
    private func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                             parameters: [String: String?],
                             responseItem: I.Type) -> AnyPublisher<[I], AFError>
    {
        guard let url = URLBuilder.buildURL(vkApiMethod, with: parameters) else { fatalError() }
        return AF.request(url).publishDecodable(type: Response<I>.self, decoder: JSON.decoder).value()
            .map { $0.response.items }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - External methods -
    func getUsers(userIds: [Int], users: @escaping ([User]) -> Void) {
        let userIds = userIds.map { String($0) }.joined(separator: ",")
        let parameters = ["user_ids": userIds, "fields": "photo_max,first_name_gen,last_name_gen"]
        makeRequest(.getUsers, parameters: parameters, responseItem: User.self) { users($0) }
    }
    
    
    func getFriends(userId: Int, friends: @escaping ([User]) -> Void) {
        let parameters = ["user_id": String(userId), "fields": "photo_max,first_name_gen,last_name_gen,home_town,bdate"]
        makeRequest(.getFriends, parameters: parameters, responseItem: User.self) { friends($0) }
    }
    
    
    func getGroups(userId: Int, groups: @escaping ([Group]) -> Void) {
        let parameters = ["user_id": String(userId), "extended": "1", "fields": "city"]
        makeRequest(.getGroups, parameters: parameters, responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int, photos: @escaping ([Photo]) -> Void) {
        let parameters = ["owner_id": String(userId), "album_id": "profile"]
        makeRequest(.getPhotos, parameters: parameters, responseItem: Photo.self) { photos($0) }
    }
    
    
    func getPosts(ownerId: Int, posts: @escaping ([Post]) -> Void) {
        makeRequest(.getPosts, parameters: ["owner_id": String(ownerId)], responseItem: Post.self) { posts($0) }
    }
    
    
    func wallPost(message: String, postId: @escaping (Int?) -> Void) {
        makeRequest(.wallPost, parameters: ["message": message], expecting: "post_id") { postId($0) }
    }
    
    
    func deletePost(postId: Int?, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.deletePost, parameters: ["post_id": String(postId)], isSuccessful: isSuccessful)
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
    
    
    func like(like: Bool = true, type: String, itemId: Int, likeCount: @escaping (Int?) -> Void) {
        let parameters = ["type": type, "item_id": String(itemId)]
        makeRequest(like ? .like : .dislike, parameters: parameters, expecting: "likes") { likeCount($0) }
    }
    
    
    // MARK: - Combine -
    private var cancellables: Set<AnyCancellable> = []
    
    
    func getFriendsGroupsPhotosAndPosts(for userId: Int, result: @escaping ([User]?, [Group]?, [Photo]?, [Post]?) -> Void) {
        let friendsParameters = ["user_id": String(userId), "fields": "photo_max,first_name_gen,last_name_gen,home_town,bdate"]
        let friendsPublisher = makeRequest(.getFriends, parameters: friendsParameters, responseItem: User.self)
        
        let groupsParameters = ["user_id": String(userId), "extended": "1", "fields": "city"]
        let groupsPublisher = makeRequest(.getGroups, parameters: groupsParameters, responseItem: Group.self)
        
        let photosParameters = ["owner_id": String(userId), "album_id": "profile"]
        let photosPublisher = makeRequest(.getPhotos, parameters: photosParameters, responseItem: Photo.self)
        
        let postsPublisher = makeRequest(.getPosts, parameters: ["owner_id": String(userId)], responseItem: Post.self)
        
        Publishers.Zip4(friendsPublisher, groupsPublisher, photosPublisher, postsPublisher)
            .sink {
                switch $0 {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: {
                result($0.0, $0.1, $0.2, $0.3)
            }
            .store(in: &cancellables)
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
    
    private enum CodingKeys: CodingKey {
        case response, items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.response = try container.decode(Items<I>.self, forKey: .response)
        } catch {
            print(error)
            self.response = Items(items: try container.decode([I].self, forKey: .response))
        }
    }
}


//
// MARK: - ResponseError
//
struct ResponseError: Decodable {
    let code: Int
    let message: String
    
    private enum CodingKeys: CodingKey {
        case error, errorCode, errorMsg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
        self.code = try errorContainer.decode(Int.self, forKey: .errorCode)
        self.message = try errorContainer.decode(String.self, forKey: .errorMsg)
    }
}
