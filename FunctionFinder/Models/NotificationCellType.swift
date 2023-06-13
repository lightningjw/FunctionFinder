//
//  NotificationCellType.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/12/23.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}
