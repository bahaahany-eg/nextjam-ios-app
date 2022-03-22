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
    let token = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.staticKeys.DeveloperToken)
    
    func createSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest{
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.music.apple.com"
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms,
                             "limit": "25",
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
        
//        let developerToken = self.token
//        print("token:=======\(self.token)")
        
        let urlRequest = createSearchRequest(with: term, countryCode: countryCode, developerToken: self.token as! String)
        print(urlRequest)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                return
            }
            
            do {
                                
                let mediaItems = try self.processMediaItemSections(from: data!)
//                print(mediaItems)
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func getPlaylistBy(id:String,success:@escaping(_ Data:[[String:Any]])->(),failure:@escaping(_ error:Error)->()){
//        print("https://api.music.apple.com/v1/catalog/us/playlists/\(id)")
        var request = URLRequest(url: URL(string: "https://api.music.apple.com/v1/catalog/us/playlists/\(id)")!,timeoutInterval: Double.infinity)
        //request.addValue("Bearer \(self.token))", forHTTPHeaderField: "Authorization")
        request.addValue("Bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IkRWVTI0NVBUOEgiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEiLCJleHAiOjE2NDU2NDU5OTgsImlzcyI6IjNBWFBBNldMN0cifQ.gCNrR8-3IeOZP3nmZCBtpqx8oWq6WSqQq_VtKGmtEe-Z2hSCp4piWUHrdXAxu7nc9tyKgZIkK0ydawJrnk-Uzw", forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"
        print(request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              failure(error!)
            return
          }
          
            do {
                
                var Tracks = [[String:Any]]()
                let d = try JSONSerialization.jsonObject(with: data, options: [.mutableLeaves])
                let arrayData = ((((d as! NSDictionary).value(forKey: "data")) as! NSArray)[0] as! NSDictionary)
                let relations = ((arrayData ).value(forKey: "relationships")! as! NSDictionary)
                let track = (relations.value(forKey: "tracks")! as! NSDictionary).value(forKey: "data")! as! NSArray
                track.forEach { singleTrack in
                    let trackID = (singleTrack as! NSDictionary).value(forKey: "id") as! String
                    let trackAtrributes = (singleTrack as! NSDictionary).value(forKey: "attributes") as! NSDictionary
                    let artworks = trackAtrributes.value(forKey: "artwork") as! NSDictionary
                    var image = (artworks.value(forKey: "url") as AnyObject).replacingOccurrences(of: "{w}", with: "300")
                    image = image.replacingOccurrences(of: "{h}", with: "300")
                    let finalImgURL = image
                    let name = trackAtrributes.value(forKey: "albumName")!
                    let artistName = trackAtrributes.value(forKey: "artistName")!
                    let trkData = ["trackID":trackID,
                           "image":finalImgURL,
                           "name":name,
                           "artistName":artistName
                          ]
                    Tracks.append(trkData)
                }
                success(Tracks)
            }catch let err{
                failure(err)
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
                
                return
            }
            do {
                let Decoder = JSONDecoder()
                let jsonObject = try Decoder.decode(TracksModel.self, from: data)
                
                let url = jsonObject.data[0].attributes.previews.first?.url
                Constants.staticKeys.USER_DEFAULTS.set(url, forKey: Constants.staticKeys.playlistdata)
                
            } catch let error{
                
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
