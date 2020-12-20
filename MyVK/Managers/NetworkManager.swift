//
//  NetworkManager.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private lazy var urlComponents: URLComponents? = {
        var components = URLComponents(string: "https://api.vk.com")
        let parameters = ["access_token" : Session.shared.token, "v" : "5.126"]
        components?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return components
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    
    func getFriends() {
        urlComponents?.path = "/method/friends.get"
        urlComponents?.queryItems?.append(URLQueryItem(name: "fields", value: "bdate"))
        guard let url = urlComponents?.url else { return }
        AF.request(url).responseDecodable(of: Response.self, decoder: decoder) { response in
            let friends = response.value?.response.items
            friends?.forEach { print($0.firstName, $0.lastName) }
        }
    }
}
