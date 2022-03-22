//
//  CreateRoomResponse.swift
//  CreateRoomResponse
//
//  Created by apple on 20/08/21.
//

import Foundation

// MARK: - CreateRoomResponse
struct CreateRoomResponse: Decodable {
    let roomID, inviteCode: String?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case inviteCode = "invite_code"
    }
}
