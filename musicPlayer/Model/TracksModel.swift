//
//  Tracks.swift
//  Tracks
//
//  Created by apple on 24/08/21.
//
import Foundation

// MARK: - TracksModel
struct TracksModel: Decodable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Decodable {
    let id: String
    let type: TTypeEnum
    let href: String
    let attributes: TAttributes
}

// MARK: - Attributes
struct TAttributes: Decodable {
    let previews: [TPreview]
    let artwork: TArtwork
    let artistName: TArtistName
    let url: String
    let discNumber: Int
    let genreNames: [String]
    let durationInMillis: Int
    let releaseDate, name, isrc: String
    let hasLyrics: Bool
    let albumName: String
    let playParams: TPlayParams
    let trackNumber: Int
    let composerName: String?
}

enum TArtistName: String, Decodable {
    case janetJackson = "Janet Jackson"
}

// MARK: - Artwork
struct TArtwork: Decodable {
    let width, height: Int
    let url, bgColor, textColor1, textColor2: String
    let textColor3, textColor4: String
}

// MARK: - PlayParams
struct TPlayParams: Decodable {
    let id: String
    let kind: TKind
}

enum TKind: String, Decodable {
    case song = "song"
}

// MARK: - Preview
struct TPreview: Decodable {
    let url: String
}

enum TTypeEnum: String, Decodable {
    case songs = "songs"
}
