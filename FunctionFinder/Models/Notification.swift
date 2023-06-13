//
//  Notification.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import Foundation

struct AppNotification: Codable {
    let identifier: String
    let notificationType: Int // 1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let username: String
    let dateString: String
    // Follow/Unfollow
    let isFollowing: Bool?
    // Like/Comment
    let postId: String?
    let postUrl: String?
}
