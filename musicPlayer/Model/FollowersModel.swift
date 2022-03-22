//
//  FollowersModel.swift
//  NextJAM
//
//  Created by apple on 12/11/21.
//

import Foundation

// MARK: - FollowerModel
struct FollowersModel: Codable {
    let users: [Followers]
}

// MARK: - User
struct Followers: Codable {
    let username: String
    let displayName: String
    let profileImage: String

    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
        case profileImage = "profile_image"
    }
}

