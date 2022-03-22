//
//  Model.swift
//  Model
//
//  Created by apple on 20/08/21.
//

import Foundation
import UIKit
class MediaItem {
    
    // MARK: Types
    
    /// The type of resource.
    enum MediaType: String {
        case songs, albums, stations, playlists
    }
    struct JSONKeys {
        static let identifier = "id"
        
        static let type = "type"
        
        static let attributes = "attributes"
        
        static let name = "name"
        
        static let artistName = "artistName"
        
        static let artwork = "artwork"
    }
    
    // MARK: Properties
    let identifier: String
    let name: String
    let artistName: String
    let artwork: Artwork
    let type: MediaType
    
    init(json: [String: Any]) throws {
        guard let identifier = json[JSONKeys.identifier] as? String else {
            throw SerializationError.missing(JSONKeys.identifier)
        }
        
        guard let typeString = json[JSONKeys.type] as? String, let type = MediaType(rawValue: typeString) else {
            throw SerializationError.missing(JSONKeys.type)
        }
        
        guard let attributes = json[JSONKeys.attributes] as? [String: Any] else {
            throw SerializationError.missing(JSONKeys.attributes)
        }
        
        guard let name = attributes[JSONKeys.name] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        let artistName = attributes[JSONKeys.artistName] as? String ?? " "
        
        guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
            throw SerializationError.missing(JSONKeys.artwork)
        }
        
        self.identifier = identifier
        self.type = type
        self.name = name
        self.artistName = artistName
        self.artwork = artwork
    }
}


struct ResponseRootJSONKeys {
    static let data = "data"
    
    static let results = "results"
}

struct ResourceJSONKeys {
    static let identifier = "id"
    
    static let attributes = "attributes"
    
    static let type = "type"
}

struct ResourceTypeJSONKeys {
    static let songs = "songs"
    
    static let albums = "albums"
}

class Artwork {
    
    // MARK: Types
    struct JSONKeys {
        static let height = "height"
        
        static let width = "width"
        
        static let url = "url"
    }
    
    // MARK: Properties
    
    let height: Int
    let width: Int
    
    var urlTemplateString: String
    
    let SongImageURL: String?
    
    
    
    // MARK: Initialization
    
    init(json: [String: Any]) throws {
        guard let height = json[JSONKeys.height] as? Int else {
            throw SerializationError.missing(JSONKeys.height)
        }
        
        guard let width = json[JSONKeys.width] as? Int else {
            throw SerializationError.missing(JSONKeys.width)
        }
        
        guard let urlTemplateString = json[JSONKeys.url] as? String else {
            throw SerializationError.missing(JSONKeys.url)
        }
        
        self.height = height
        self.width = width
        self.urlTemplateString = urlTemplateString
        
        self.urlTemplateString = self.urlTemplateString.replacingOccurrences(of: "{w}", with: "1200")
        self.urlTemplateString = self.urlTemplateString.replacingOccurrences(of: "{h}", with: "1200")
        
        SongImageURL = self.urlTemplateString
        
    }
    
    // MARK: Image URL Generation Method
    
    func imageURL(size: CGSize) -> URL {
        var imageURLString = urlTemplateString.replacingOccurrences(of: "{w}", with: "\(Int(size.width))")
        imageURLString = imageURLString.replacingOccurrences(of: "{h}", with: "\(Int(size.width))")
        imageURLString = imageURLString.replacingOccurrences(of: "{f}", with: "png")
        return URL(string: imageURLString)!
    }

}
