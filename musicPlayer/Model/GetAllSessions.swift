
import Foundation

// MARK: - GetAllSessionModel
struct GetAllSessionModel: Codable {
    let rooms: [Room]
}

// MARK: - Room
struct Room: Codable {
    let roomName: String
    let roomID: String
    let inviteCode: String
    let startsAt: String
    let hostDisplayName : String
    let hostUsername: String
    let hostProfileImage: String?
    let roomStatus: String

    enum CodingKeys: String, CodingKey {
        case roomName = "room_name"
        case roomID = "room_id"
        case inviteCode = "invite_code"
        case startsAt = "starts_at"
        case hostDisplayName = "host_display_name"
        case hostUsername = "host_username"
        case hostProfileImage = "host_profile_image"
        case roomStatus = "room_status"
    }
}
