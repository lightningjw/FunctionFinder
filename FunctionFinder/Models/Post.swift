//
//  Post.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import Foundation

public struct Post: Codable {
    let id: String
    let caption: String
    let postedDate: String
    let postUrlString: String
    var likers: [String]
    
    var date: Date {
        return DateFormatter.formatter.date(from: postedDate) ?? Date()
    }
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username")
        else {
            return nil
        }
        return "\(username)/posts/\(id)/png"
    }
}


public enum UserPostType: String {
    case photo = "Photo"
    case video = "Video"
}

/// Represents a user post
public struct UserPost {
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL // either video url or full resolution photo
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdDate: Date
    let taggedUsers: [String]
    let owner: User
}

struct PostLike {
    let username: String
    let postIdentifier: String
}

struct CommentLike {
    let username: String
    let commentIdentifier: String
}

struct PostComment {
    let identifier: String
    let username: String
    let text: String
    let createdDate: Date
    let likes: [CommentLike]
}
