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
    @objc dynamic var date = ""
    @objc dynamic var text: String? = nil
    @objc dynamic var likeCount = 0
    @objc dynamic var likedByCurrentUser = false
    @objc dynamic var viewCount: String? = nil
    @objc dynamic var userOwner: User?
    @objc dynamic var groupOwner: Group?
    @objc dynamic var attachmentsString: String? = nil
    let attachments = List<String>()
    let photos = List<Photo>()
    
    
    override class func primaryKey() -> String? { "id" }
}


// MARK: - Computed properties -
extension Post {
    
    private var _attachmentsString: String? {
        guard !attachments.isEmpty else { return nil }
        return "[" + attachments.joined(separator: ", ").uppercased() + "]"
    }
}


//
// MARK: - Decodable -
//
extension Post: Decodable {
    
    private enum CodingKeys: CodingKey {
        case id, sourceId, ownerId, postId, date, text, likes, count, userLikes, views, attachments, type, photo, copyHistory
    }
    
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.sourceId = try container.decode(Int.self, forKey: .sourceId)
        } catch {
            self.sourceId = (try? container.decode(Int.self, forKey: .ownerId)) ?? 0
        }
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
        let date = try container.decode(Int.self, forKey: .date)
        self.date = F.fd(date)
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
                if type != "photo" {
                    self.attachments.append(type)
                }
                if let photo = try? attachmentContainer.decode(Photo.self, forKey: .photo) {
                    self.photos.append(photo)
                }
            }
        }
        self.attachmentsString = _attachmentsString
        self.text = try? container.decode(String.self, forKey: .text)
    }
}
