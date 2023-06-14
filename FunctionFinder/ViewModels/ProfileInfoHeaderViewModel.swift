//
//  ProfileInfoHeaderViewModel.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/13/23.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileInfoHeaderViewModel {
    let profilePictureUrl: URL?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let name: String?
    let bio: String?
}
