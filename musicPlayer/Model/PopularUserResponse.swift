//
//  PopularUserResponse.swift
//  NextJAM
//
//  Created by apple on 14/09/21.
//

import Foundation

// MARK: - PopularUserResponse
struct PopularUserResponse: Codable {
    var users: [User]
}

// MARK: - User
struct User: Codable {
    var displayName: String
    var username: String
    var followCount: Int
    var profileImage: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case username
        case followCount = "follow_count"
        case profileImage = "profile_image"
    }
}
