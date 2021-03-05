//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Foundation
import Alamofire
import Combine

final class NetworkManager {
    
    // MARK: - Singleton -
    static let shared = NetworkManager()
    
    
    // MARK: - Initialization -
    private init() {
        self.retrier = NetworkManagerRetrier()
        self.session = Session(configuration: configuration, rootQueue: queue, interceptor: retrier)
    }
    
    
    // MARK: - Internal properties -
    private let session: Session
    private let retrier: RequestInterceptor
    private let queue = DispatchQueue(label: "com.pgc6240.MyVK.alamofire", qos: .userInteractive)
    private let configuration: URLSessionConfiguration = {
        let configuration                  = URLSessionConfiguration.default
        configuration.requestCachePolicy   = .reloadRevalidatingCacheData
        configuration.waitsForConnectivity = true
        return configuration
    }()
}
   

//
// MARK: - Internal methods -
//
private extension NetworkManager {
    
    func request(_ vkApiMethod: VKApiMethod, parameters: Parameters?) -> DataRequest {
        session.request(vkApiMethod, parameters: parameters).validate()
    }
    
    
    func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                                   parameters: Parameters?,
                                   responseItem: I.Type,
                                   completion: @escaping ([I]) -> Void)
    {
        request(vkApiMethod, parameters: parameters).responseDecodable(of: Response<I>.self, decoder: JSON.decoder) {
            [weak self] in
            switch $0.result {
            case .success(let response):
                completion(response.items)
            case .failure(let error):
                self?.handleError(error, data: $0.data, url: $0.request?.url)
            }
        }
    }
    
    
    func makeRequest(_ vkApiMethod: VKApiMethod,
                     parameters: Parameters?,
                     isSuccessful: @escaping (Bool) -> Void)
    {
        request(vkApiMethod, parameters: parameters).responseJSON {
            // Sample response JSON: { "response": 1 }
            isSuccessful(($0.value as? [String: Int])?["response"] == 1)
        }
    }
    
    
    func makeRequest(_ vkApiMethod: VKApiMethod,
                     parameters: Parameters?,
                     expecting: String,
                     number: @escaping (Int?) -> Void)
    {
        request(vkApiMethod, parameters: parameters).responseJSON {
            // Sample response JSON: { "response": { "likes": 12 }}
            number((($0.value as? [String: Any])?["response"] as? [String: Any])?[expecting] as? Int)
        }
    }
    
    
    func makeRequest<I: Decodable>(_ vkApiMethod: VKApiMethod,
                                   parameters: Parameters?,
                                   responseItem: I.Type) -> AnyPublisher<Response<I>?, Never>
    {
        request(vkApiMethod, parameters: parameters).publishDecodable(type: Response<I>.self, decoder: JSON.decoder)
            .map { [weak self] in
                if let error = $0.error {
                    self?.handleError(error, data: $0.data, url: $0.request?.url)
                }
                return $0.value
            }
            .eraseToAnyPublisher()
    }
    
    
    func makeRequest(_ vkApiMethod: VKApiMethod,
                     parameters: Parameters?,
                     expecting: String) -> AnyPublisher<Int?, Never>
    {
        request(vkApiMethod, parameters: parameters).publishResponse(using: JSONResponseSerializer())
            .map { (($0.value as? [String: Any])?["response"] as? [String: Any])?[expecting] as? Int }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Error handling -
    func handleError(_ error: AFError, data: Data?, url: URL?) {
        #if DEBUG
        if let data = data, let responseError = try? JSON.decoder.decode(ResponseError.self, from: data) {
            print(responseError.code, responseError.message)
        } else if !error.isExplicitlyCancelledError {
            print(url ?? "", error)
        }
        #endif
    }
}
  

//
// MARK: - External methods -
//
extension NetworkManager {
    
    func getUsers(userIds: [Int], users: @escaping ([User]) -> Void) {
        let userIds = userIds.map { String($0) }.joined(separator: ",")
        makeRequest(.getUsers, parameters: ["user_ids": userIds], responseItem: User.self) { users($0) }
    }
    
    
    func getFriends(userId: Int, friends: @escaping ([User]) -> Void) {
        makeRequest(.getFriends, parameters: ["user_id": userId], responseItem: User.self) { friends($0) }
    }
    
    
    func getFriends(for userId: Int, friends: @escaping ([User]?) -> Void) -> AnyCancellable {
        makeRequest(.getFriends, parameters: ["user_id": userId], responseItem: User.self)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sink { friends($0?.items) }
    }
    
    
    func getGroups(for userId: Int, groups: @escaping ([Group]) -> Void) {
        makeRequest(.getGroups, parameters: ["user_id": userId], responseItem: Group.self) { groups($0) }
    }
    
    
    func getPhotos(for userId: Int, photos: @escaping ([Photo]) -> Void) {
        makeRequest(.getPhotos, parameters: ["owner_id": userId], responseItem: Photo.self) { photos($0) }
    }
    
    
    func getPosts(ownerId: Int, posts: @escaping ([Post]?, Int?) -> Void) -> AnyCancellable {
        makeRequest(.getPosts, parameters: ["owner_id": ownerId], responseItem: Post.self)
            .sink { posts($0?.items, $0?.count) }
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
    
    
    func getGroups(groupIds: [Int], groups: @escaping ([Group]) -> Void) {
        let groupIds = groupIds.map { String($0) }.joined(separator: ",")
        makeRequest(.getGroupsById, parameters: ["group_ids": groupIds], responseItem: Group.self) { groups($0) }
    }
    
    
    func like(like: Bool = true, type: String, itemId: Int, likeCount: @escaping (Int?) -> Void) {
        let method: VKApiMethod = like ? .like : .dislike
        makeRequest(method, parameters: ["type": type, "item_id": itemId], expecting: "likes") { likeCount($0) }
    }
    
    
    func searchUsers(_ q: String, users: @escaping ([User]) -> Void) {
        makeRequest(.searchUsers, parameters: ["q": q], responseItem: User.self, completion: users)
    }
    
    
    func addFriend(with userId: Int, isSuccessful: @escaping (Bool) -> Void) {
        makeRequest(.addFriend, parameters: ["user_id": userId], isSuccessful: isSuccessful)
    }
}


//
// MARK: - Response -
//
fileprivate struct Response<I: Decodable>: Decodable {
    
    var items: [I]
    let count: Int?
    
    private enum CodingKeys: CodingKey {
        case response, items, count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let responseContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
            self.items = try responseContainer.decode([I].self, forKey: .items)
            self.count = try responseContainer.decode(Int.self, forKey: .count)
        } catch {
            self.items = try container.decode([I].self, forKey: .response)
            self.count = try? container.decode(Int.self, forKey: .count)
        }
    }
}


//
// MARK: - ResponseError -
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


//
// MARK: - NetworkManagerRetrier -
//
private extension NetworkManager {
    
    struct NetworkManagerRetrier: RequestInterceptor {
        
        let networkReachabilityManager = NetworkReachabilityManager(host: "yandex.ru")
        let retryLimit                 = 3
        let retryDelay: TimeInterval   = 3
        
        
        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
            if let afError  = error as? AFError,
               let urlError = afError.underlyingError as? URLError,
               (urlError.code == .timedOut || urlError.code == .notConnectedToInternet)
            {
                networkReachabilityManager?.startListening { status in
                    switch status {
                    case .reachable(_):
                        networkReachabilityManager?.stopListening()
                        completion(.retry)
                    default: break
                    }
                }
            } else if let response = request.task?.response as? HTTPURLResponse,
                      response.statusCode == 200,
                      request.retryCount < retryLimit
            {
                completion(.retryWithDelay(retryDelay))
            } else {
                completion(.doNotRetry)
            }
        }
    }
}
