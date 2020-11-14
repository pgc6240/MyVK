//
//  Attachment.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

enum AttachmentType {
    case photo
}

protocol Attachable {
    var type: AttachmentType { get }
}
