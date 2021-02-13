//
//  GetNewsfeedOp.swift
//  MyVK
//
//  Created by pgc6240 on 13.02.2021.
//

import Alamofire

final class GetNewsfeedOperation: AsyncOperation {
    
    var posts: [Post]?
    var nextFrom: String?
    
    private let startFrom: String?
    private var request: DataRequest?
    
    
    init(startFrom: String?) {
        self.startFrom = startFrom
        super.init()
    }
    
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
    
    
    override func main() {
        let method: VKApiMethod    = .getNewsfeed
        let parameters: Parameters = startFrom == nil ? [:] : ["start_from": startFrom!]
        
        request = AF.request(method, parameters: parameters).responseDecodable(of: Newsfeed.self, decoder: JSON.decoder) {
            [weak self] in
            guard let self = self, !self.isCancelled else { return }
            defer { self.state = .finished }
            
            switch $0.result {
            case .success(let newsfeed):
                self.posts     = newsfeed.parse()
                self.nextFrom  = newsfeed.response.nextFrom
            case .failure(let error):
                print(error)
            }
        }
    }
}


//
// MARK: - Newsfeed -
//
fileprivate struct Newsfeed: Decodable {
    
    let response: Response
    
    struct Response: Decodable {
        let items: [Post]
        let groups: [Group]
        let profiles: [User]
        let nextFrom: String?
    }
    
    
    func parse() -> [Post] {
        for post in response.items {
            if let userOwner = response.profiles.first(where: { $0.id == post.sourceId }) {
                post.userOwner = userOwner
            } else if let groupOwner = response.groups.first(where: { $0.id == -post.sourceId }) {
                post.groupOwner = groupOwner
            }
        }
        return response.items
    }
}
