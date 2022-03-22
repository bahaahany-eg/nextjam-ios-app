//
//  Playlist.swift
//  Playlist
//
//  Created by apple on 22/08/21.
//

import Foundation

// MARK: - PlayList
struct PlayListModel: Decodable {
    let data: [PlayListDatum]
}

// MARK: - PlayListDatum
struct PlayListDatum: Decodable {
    let id, type, href: String
    let attributes: PurpleAttributes
    let relationships: Relationships
}

// MARK: - PurpleAttributes
struct PurpleAttributes: Decodable {
    let artwork: PArtwork
    let isChart: Bool
    let url: String

    let name, playlistType, curatorName: String
    let playParams: PlayParams
    let attributesDescription: Description

    enum CodingKeys: String, CodingKey {
        case artwork, isChart, url, name, playlistType, curatorName, playParams
        case attributesDescription = "description"
    }
}

// MARK: - Artwork
struct PArtwork: Decodable {
    let width, height: Int
    let url, bgColor, textColor1, textColor2: String
    let textColor3, textColor4: String
}

// MARK: - Description
struct Description: Decodable {
    let standard, short: String
}

// MARK: - PlayParams
struct PlayParams: Decodable {
    let id: String
    let kind: Kind
}

enum Kind: String, Decodable {
    case playlist = "playlist"
    case song = "song"
}

// MARK: - Relationships
struct Relationships: Decodable {
    let tracks, curator: Curator
}

// MARK: - Curator
struct Curator: Decodable {
    let href: String
    let data: [CuratorDatum]
}

// MARK: - CuratorDatum
struct CuratorDatum: Decodable {
    let id: String

    let href: String

}


enum ArtistName: String, Decodable {
    case janetJackson = "Janet Jackson"
}

// MARK: - Preview
struct Preview: Decodable {
    let url: String
}

enum TypeEnum: String, Decodable {
    case songs = "songs"
}
