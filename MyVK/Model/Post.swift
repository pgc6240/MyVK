//
//  Post.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import Foundation
import RealmSwift

final class Post: Object, Identifiable {

    @objc dynamic var id = 0
    @objc dynamic var sourceId = 0
    @objc dynamic var date = 0 /* unixtime */
    @objc dynamic var text: String? = nil
    @objc dynamic var likeCount = 0
    @objc dynamic var likedByCurrentUser = false
    @objc dynamic var viewCount: String? = nil
    @objc dynamic var userOwner: User?
    @objc dynamic var groupOwner: Group?
    let attachments = List<Attachment>()
    
    
    override class func primaryKey() -> String? { "id" }
}


//
// MARK: - Decodable -
//
extension Post: Decodable {
    
    private enum CodingKeys: CodingKey {
        case id, sourceId, postId, date, text
        case likes, count, userLikes
        case views
        case attachments, type, photo
        case copyHistory
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.sourceId = (try? container.decode(Int.self, forKey: .sourceId)) ?? 0
        if var copyHistoryContainer = try? container.nestedUnkeyedContainer(forKey: .copyHistory) {
            while !copyHistoryContainer.isAtEnd {
                container = try copyHistoryContainer.nestedContainer(keyedBy: CodingKeys.self)
            }
        }
        do {
            self.id = try container.decode(Int.self, forKey: .id)
        } catch {
            self.id = try container.decode(Int.self, forKey: .postId)
        }
        self.date = try container.decode(Int.self, forKey: .date)
        self.text = try? container.decode(String.self, forKey: .text)
        if let likesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes) {
            self.likeCount = try likesContainer.decode(Int.self, forKey: .count)
            let userLikes = try likesContainer.decode(Int.self, forKey: .userLikes)
            self.likedByCurrentUser = userLikes == 1
        }
        let viewsContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .views)
        let viewCount = try? viewsContainer?.decode(Int.self, forKey: .count)
        self.viewCount = F.fn(viewCount)
        if var attachmentsContainer = try? container.nestedUnkeyedContainer(forKey: .attachments) {
            while !attachmentsContainer.isAtEnd {
                let attachmentContainer = try attachmentsContainer.nestedContainer(keyedBy: CodingKeys.self)
                let type = try attachmentContainer.decode(String.self, forKey: .type)
                let photo = try? attachmentContainer.decode(Photo.self, forKey: .photo)
                self.attachments.append(Attachment(type: type, photo: photo))
            }
        }
    }
}


//
// MARK: - Attachment -
//
final class Attachment: Object, Decodable {
    
    @objc dynamic var type = ""
    @objc dynamic var photo: Photo?
    
    
    convenience init(type: String, photo: Photo?) {
        self.init()
        self.type = type
        self.photo = photo
    }
}


//
// MARK: - Newsfeed -
//
struct Newsfeed: Decodable {
    
    private let response: Response
    
    private struct Response: Decodable {
        let items: [Post]
        let groups: [Group]
        let profiles: [User]
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
