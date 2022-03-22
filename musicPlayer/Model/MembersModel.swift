//
//  MembersModel.swift
//  NextJAM
//
//  Created by iOS Dev on 06/12/21.
//


import Foundation

// MARK: - MembersModel
struct MembersModel: Codable {
    let attendees: [Attendee]
}

// MARK: - Attendee
struct Attendee: Codable {
    let displayName, username, profileImage: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case username
        case profileImage = "profile_image"
    }
}
