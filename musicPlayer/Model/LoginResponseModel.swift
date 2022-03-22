//
//  LoginResponseModel.swift
//  musicPlayer
//
//  Created by apple on 19/08/21.
//

import Foundation

// MARK: - LoginResponceModel
struct LoginResponceModel: Codable {
    var displayName:String
    let jsonWebToken: String
    let musicAPIToken: String
    let profileImage: String
    var username: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case jsonWebToken = "access_token"
        case musicAPIToken = "music_api_token"
        case profileImage = "profile_image"
        case username
    }
}
