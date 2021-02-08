//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Alamofire
import Combine
import Foundation

final class NetworkManager {
    
    // MARK: - Singleton -
    static let shared = NetworkManager()
    
    private init() {}
    
    
    // MARK: - Internal methods -
    private func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                                           parameters: Parameters?,
                                           responseItem: I.Type,
                                           completion: @escaping ([I]) -> Void)
    {
        AF.request(vkApiMethod, parameters: parameters).responseDecodable(of: Response<I>.self, decoder: JSON.decoder) {
            [weak self] in
            switch $0.result {
            case .success(let response):
                completion(response.items)
            case .failure(let error):
                self?.handleError(error, data: $0.data)
            }
        }
    }
    
    
    private func makeRequest(_ vkApiMethod: VKApiMethod,
                             parameters: Parameters?,
                             isSuccessful: @escaping (Bool) -> Void)
    {
        AF.request(vkApiMethod, parameters: parameters).responseJSON {
            /* Sample response JSON: { "response": 1 } */
            isSuccessful(($0.value as? [String: Int])?["response"] == 1)
        }
    }
    
    
    private func makeRequest(_ vkApiMethod: VKApiMethod,
                             parameters: Parameters?,
                             expecting: String,
                             number: @escaping (Int?) -> Void)
    {
        AF.request(vkApiMethod, parameters: parameters).responseJSON {
            /* Sample response JSON: { "response": { "likes": 12 } } */
            number((($0.value as? [String: Any])?["response"] as? [String: Any])?[expecting] as? Int)
        }
    }
    
    
    private func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                             parameters: Parameters?,
                             responseItem: I.Type) -> AnyPublisher<[I]?, Never>
    {
        AF.request(vkApiMethod, parameters: parameters).publishDecodable(type: Response<I>.self, decoder: JSON.decoder)
            .retry(2)
            .map { [weak self] in
                if let error = $0.error {
                    self?.handleError(error, data: $0.data)
                }
                return $0.value?.items
            }
            .eraseToAnyPublisher()
    }
    
    
    private func makeRequest(_ vkApiMethod: VKApiMethod,
                             parameters: Parameters?,
                             expecting: String) -> AnyPublisher<Int?, Never>
    {
        AF.request(vkApiMethod, parameters: parameters).publishResponse(using: JSONResponseSerializer())
            .retry(2)
            .map { (($0.value as? [String: Any])?["response"] as? [String: Any])?[expecting] as? Int }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Error handling -
    private func handleError(_ error: AFError, data: Data?) {
        if let data = data, let responseError = try? JSON.decoder.decode(ResponseError.self, from: data) {
            print(responseError.code, responseError.message)
        } else {
            guard !error.isExplicitlyCancelledError else { return }
            print(error)
        }
    }
    
    
    // MARK: - External methods -
    func getUsers(userIds: [Int], users: @escaping ([User]) -> Void) {
        let userIds = userIds.map { String($0) }.joined(separator: ",")
        makeRequest(.getUsers, parameters: ["user_ids": userIds], responseItem: User.self) { users($0) }
    }
    
    
    func getFriends(userId: Int, friends: @escaping ([User]) -> Void) {
        makeRequest(.getFriends, parameters: ["user_id": userId], responseItem: User.self) { friends($0) }
    }
    
    
    func getGroups(userId: Int, groups: @escaping ([Group]) -> Void) {
        makeRequest(.getGroups, parameters: ["user_id": userId], responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int, photos: @escaping ([Photo]) -> Void) {
        makeRequest(.getPhotos, parameters: ["owner_id": userId], responseItem: Photo.self) { photos($0) }
    }
    
    
    func getPosts(ownerId: Int, posts: @escaping ([Post]) -> Void) {
        makeRequest(.getPosts, parameters: ["owner_id": ownerId], responseItem: Post.self) { posts($0) }
    }
    
    
    func wallPost(message: String, postId: @escaping (Int?) -> Void) {
        makeRequest(.wallPost, parameters: ["message": message], expecting: "post_id") { postId($0) }
    }
    
    
    func deletePost(postId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.deletePost, parameters: ["post_id": postId], isSuccessful: isSuccessful)
    }
    
    
    func searchGroups(_ searchQuery: String, searchResults: @escaping ([Group]) -> Void) {
        makeRequest(.searchGroups, parameters: ["q": searchQuery], responseItem: Group.self) { searchResults($0) }
    }
    
    
    func joinGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.joinGroup, parameters: ["group_id": groupId], isSuccessful: isSuccessful)
    }
    
    
    func leaveGroup(groupId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.leaveGroup, parameters: ["group_id": groupId], isSuccessful: isSuccessful)
    }
    
    
    func like(like: Bool = true, type: String, itemId: Int, likeCount: @escaping (Int?) -> Void) {
        let method: VKApiMethod = like ? .like : .dislike
        makeRequest(method, parameters: ["type": type, "item_id": itemId], expecting: "likes") { likeCount($0) }
    }
    
    
    // MARK: - Combine -
    private var cancellables: Set<AnyCancellable> = []
    
    
    func getFriendsGroupsPhotosAndPosts(for ownerId: Int, result: @escaping ([User]?, [Group]?, [Photo]?, [Post]?) -> Void) -> AnyCancellable {
        
        let friendsPublisher = makeRequest(.getFriends, parameters: ["user_id": ownerId], responseItem: User.self)
        let groupsPublisher = makeRequest(.getGroups, parameters: ["user_id": ownerId], responseItem: Group.self)
        let photosPublisher = makeRequest(.getPhotos, parameters: ["owner_id": ownerId], responseItem: Photo.self)
        let postsPublisher = makeRequest(.getPosts, parameters: ["owner_id": ownerId], responseItem: Post.self)
        
        return Publishers.Zip4(friendsPublisher, groupsPublisher, photosPublisher, postsPublisher)
            .sink {
                result($0.0, $0.1, $0.2, $0.3)
            }
    }
    
    
    func getMembersPhotosAndPostsCount(for groupId: Int, result: @escaping (Int?, Int?, Int?) -> Void) {
        
        let memberPublisher = makeRequest(.getMembers, parameters: ["group_id": groupId], expecting: "count")
        let photosPublisher = makeRequest(.getPhotos, parameters: ["owner_id": -groupId], expecting: "count")
        let postsPublisher = makeRequest(.getPosts, parameters: ["owner_id": -groupId], expecting: "count")
            
        Publishers.Zip3(memberPublisher, photosPublisher, postsPublisher)
            .sink {
                result($0.0, $0.1, $0.2)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Newsfeed -
    func getNewsfeed(posts: @escaping ([Post]) -> Void) {
        AF.request(VKApiMethod.getNewsfeed).responseDecodable(of: Newsfeed.self, decoder: JSON.decoder) { [weak self] in
            switch $0.result {
            case .success(let newsfeed):
                posts(newsfeed.parse())
            case .failure(let error):
                self?.handleError(error, data: $0.data)
            }
        }
    }
}


//
// MARK: - Response -
//
fileprivate struct Response<I: Decodable>: Decodable {
    
    let items: [I]
    
    private enum CodingKeys: CodingKey {
        case response, items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let responseContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
            self.items = try responseContainer.decode([I].self, forKey: .items)
        } catch let error1 {
            do {
                self.items = try container.decode([I].self, forKey: .response)
            } catch let error2 {
                print(error1, error2)
                self.items = []
            }
        }
    }
}


//
// MARK: - ResponseError
//
fileprivate struct ResponseError: Decodable {
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
