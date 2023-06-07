//
//  User.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import Foundation

enum Gender {
    case male, female, other
}

struct User: Codable {
    let username: String
    let email: String
//    let bio: String
//    let name: (first: String, last: String)
//    let profilePhoto: URL
//    let birthDate: Date
//    let gender: Gender
//    let counts: UserCount
//    let joinDate: Date
}

struct UserCount {
    let followers: Int
    let following: Int
    let posts: Int
}
