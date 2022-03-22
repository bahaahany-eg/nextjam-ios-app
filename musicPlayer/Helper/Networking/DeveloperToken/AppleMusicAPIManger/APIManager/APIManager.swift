//
//  APIManager.swift
//  APIManager
//
//  Created by apple on 20/08/21.
//

import Foundation
import StoreKit
class APIManager {
    
    lazy var urlSession: URLSession = {
        let urlSessionConfiguration = URLSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    func fetchDeveloperToken() -> String? {
        
        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
        let developerAuthenticationToken = "eyJraWQiOiJEVlUyNDVQVDhIIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiIzQVhQQTZXTDdHIiwiZXhwIjo2MDAwMDAsImF1ZCI6ImFwcHN0b3JlY29ubmVjdC12MSJ9._kz6BLn3VHtkNV2i0l7FM0bJ50jdZ2IamzhOt01kIx0"
        return developerAuthenticationToken
    }
    
    func createSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest{
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.music.apple.com"
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms,
                             "limit": "7",
                             "types": "songs",
                             "with": "topResults"]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    func processMediaItemSections(from json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
              let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
            throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        print(jsonDictionary)
        
        var mediaItems = [[MediaItem]]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        
        return mediaItems
    }
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void) {
        
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
        print(urlRequest)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                return
            }
            
            do {
                                
                let mediaItems = try self.processMediaItemSections(from: data!)
                print(mediaItems)
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func getContryCode() -> String? {
        var contryCode = ""
        SKCloudServiceController().requestStorefrontCountryCode { (code, error) in
            if let CCode = code ,error == nil {
                contryCode = CCode
            } else {
                print(error as Any)
            }
        }
        return contryCode
    }
    
    func fetchTracks(){
        
        var request = URLRequest(url: URL(string: "https://api.music.apple.com/v1/catalog/us/playlists/pl.acc464c750b94302b8806e5fcbe56e17/tracks")!,timeoutInterval: Double.infinity)
        request.addValue("", forHTTPHeaderField: "")
        request.addValue("Bearer eyJraWQiOiI2VUdBNkNNRlBXIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiI5UzRHNU0yNldIIiwiZXhwIjoxNjMwNDEwOTg3LCJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEifQ.KKLn31Ec4F3PrrEqqsvdMRK3YYomFtjU_EmnSqc80huN5u8d-NLl2BrV7DbX5d3DpmCQkJ6DyhV8ynVKxHLKWw", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let Decoder = JSONDecoder()
                let jsonObject = try Decoder.decode(TracksModel.self, from: data)
                print(jsonObject)
                let url = jsonObject.data[0].attributes.previews.first?.url
                Constants.staticString.USER_DEFAULTS.set(url, forKey: Constants.staticString.playlistdata)
                
            } catch let error{
                print(error)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
