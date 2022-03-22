//
//  ImportedPlaylistModel.swift
//  NextJAM
//
//  Created by apple on 24/11/21.
//


import Foundation

// MARK: - ImportedPlaylistModeI
struct ImportedPlaylistModel: Codable {
    var data: [ImportedPlaylist]
}

// MARK: - ImportedPlaylist
struct ImportedPlaylist: Codable {
    var id, type, href: String
    var attributes: PlPurpleAttributes
    var relationships: PlRelationships
}

// MARK: - PurpleAttributes
struct PlPurpleAttributes: Codable {
    var artwork: PlaylistArtwork
    var isChart: Bool
    var url: String
    var lastModifiedDate: Date
    var name, playlistType, curatorName: String
    var playParams: PlPurplePlayParams
    var attributesDescription: PlDescription
    enum CodingKeys: String, CodingKey {
        case artwork, isChart, url, lastModifiedDate, name, playlistType, curatorName, playParams
        case attributesDescription = "description"
    }
}

// MARK: - Artwork
struct PlaylistArtwork: Codable {
    var width, height: Int
    var url, bgColor, textColor1, textColor2: String
    var textColor3, textColor4: String
}

// MARK: - Description
struct PlDescription: Codable {
    var standard: String
}

// MARK: - PurplePlayParams
struct PlPurplePlayParams: Codable {
    var id, kind, versionHash: String
}

// MARK: - Relationships
struct PlRelationships: Codable {
    var tracks, curator: PlCurator
}

// MARK: - Curator
struct PlCurator: Codable {
    var href: String
    var data: [PlCuratorDatum]
}

// MARK: - CuratorDatum
struct PlCuratorDatum: Codable {
    var id: String
    var href: String
    var attributes: PLFluffyAttributes
}

// MARK: - FluffyAttributes
struct PLFluffyAttributes: Codable {
    var previews: [PlPreview]
    var artwork: PlaylistArtwork
    var artistName: String
    var url: String
    var discNumber: Int
    var genreNames: [String]
    var durationInMillis: Int
    var releaseDate, name, isrc: String
    var hasLyrics: Bool
    var albumName: String
    var playParams: FluffyPlayParams
    var trackNumber: Int
    var composerName: String?
}

// MARK: - FluffyPlayParams
struct FluffyPlayParams: Codable {
    var id: String
    var kind: PlKind
}

enum PlKind: String, Codable {
    case song = "song"
}

// MARK: - Preview
struct PlPreview: Codable {
    var url: String
}
