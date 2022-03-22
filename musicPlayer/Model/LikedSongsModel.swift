//
//  LikedSongsModel.swift
//  Pods
//
//  Created by apple on 23/11/21.
//


import Foundation

// MARK: - LikedSongs
struct LikedSongs: Codable {
    var songs: [likedSong]
}

// MARK: - Song
struct likedSong: Codable {
    var artistName, songTitle, imageURL, name: String

    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case songTitle = "song_title"
        case imageURL = "image_url"
        case name
    }
}

