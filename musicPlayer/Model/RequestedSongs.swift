//
//  File.swift
//  NextJAM
//
//  Created by apple on 03/09/21.
//
import Foundation

// MARK: - RequestedSongs
struct RequestedSongs: Codable {
    let songs: [SongDetails]
    let currentlyPlaying :CurrentlyPlaying?
    
    enum CodingKeys: String, CodingKey {
        case currentlyPlaying = "currently_playing"
        case songs
    }
    
}

/*
 "currently_playing": {
        "artist_name": "",
        "song_title": "",
        "image_url": "",
        "name": "",
        "user_data": {
            "username": "",
            "display_name": "",
            "profile_image": ""
        }
    }
*/

struct CurrentlyPlaying: Codable {
    let artistName: String?
    let songTitle: String?
    let songImage: String?
    let name: String?
    let userData : UserData
    
    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case songTitle = "song_title"
        case songImage = "image_url"
        case name
        case userData = "user_data"
    }
}

// MARK: - Song
struct SongDetails: Codable {
    let artistName  : String
    let songTitle   : String
    let songImage   : String
    let name        : String
    let userData    : UserData

    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case songTitle = "song_title"
        case songImage = "image_url"
        case name
        case userData = "user_data"
    }
}

// MARK: - UserData
struct UserData: Codable {
    let username      : String
    let displayName   : String
    let profileImage  : String

    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
        case profileImage = "profile_image"
    }
}
