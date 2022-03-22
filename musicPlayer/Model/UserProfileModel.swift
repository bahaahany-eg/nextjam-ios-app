//
//  UserProfileModel.swift
//  NextJAM
//
//  Created by apple on 11/11/21.
//
import Foundation
// MARK: - ProfileModel

struct UserProfileModel: Codable {
    let displayName: String
    let username: String
    let profileImage: String
    let isFollowing :Bool
    let followerCount : Int
    

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case username
        case isFollowing = "is_following"
        case profileImage = "profile_image"
        case followerCount = "follower_count"
    }
}


/*
 {
     "display_name": "t1",
     "username": "t1",
     "follower_count": 0,
     "profile_image": "",
     "is_following": false
 }
 */
