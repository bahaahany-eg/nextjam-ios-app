//
//  WebLayerUserAPI+RoomExtension.swift
//  NextJAM
//
//  Created by apple on 11/11/21.
//

import Foundation

//MARK: - Extension for Room API

extension WebLayerUserAPI {
    
    //MARK: - Create Room API
    func createRoom(url: URL,parameters: [String:Any],username: String,success : @escaping(_ data: CreateRoomResponse) -> (),failure: @escaping(_ error: Error) -> ()){
        let rawJSON = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(username)", forHTTPHeaderField: "username")
        request.httpMethod = "POST"
        request.httpBody = rawJSON
        print("*****Create Room API*****")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            print(data)
            print(error?.localizedDescription)
            print(response)
            
            guard let data = data else {
                
                return
            }
            
            do {
                let roomCreatedSuccess = try JSONDecoder().decode(CreateRoomResponse.self, from: data)
                Constants.staticKeys.USER_DEFAULTS.set(roomCreatedSuccess.roomID, forKey: Constants.staticKeys.roomID)
                Constants.staticKeys.USER_DEFAULTS.set(roomCreatedSuccess.inviteCode, forKey: Constants.staticKeys.invitationCode)
                success(roomCreatedSuccess)
            }catch {
                failure(error)
            }
        }
        task.resume()
    }
    
    func DeleteRoom(for user:String,with roomID:String,success: @escaping(_ status:Bool)->(),failure:@escaping(_ error:String)->()){
        
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.DeleteRoom)\(roomID)")!,timeoutInterval: Double.infinity)
        request.addValue(user, forHTTPHeaderField: "username")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              failure(error!.localizedDescription)
            return
          }
            let statusCode = (response as! HTTPURLResponse).statusCode
            print(String(data: data, encoding: .utf8)!)
            if statusCode == 200 {
                success(true)
            }else {
                success(false)
            }
        }
        task.resume()
    }
    
    
    //MARK: - Delete song from playlist
    func deleteSomgfromPlaylist(with roomID: String,with ID:String, success: @escaping(_ response:Bool) -> (), failure: @escaping(_ error: Error)-> ()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/rooms/\(roomID)/\(ID)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            
              guard let err = error else {
                  return
              }
              failure(err)
            return
          }
//          print(String(data: data, encoding: .utf8)!)
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 204{
                success(true)
            }else{
                success(false)
            }
        }

        task.resume()
    }
    
    
    //MARK: - Fetch Songs list API
    func fetchSongsListFromServer(roomId: String, success: @escaping(_ data: RequestedSongs) -> (), failure : @escaping(_ error: Error) -> ()){
        let urlstring = Constants.APIUrls.GetSesssionSongs+roomId
        guard let url = URL(string: urlstring) else { return }
        print(url)
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        print("*****fetchSongAPI*****")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let songsJSON = try JSONDecoder().decode(RequestedSongs.self, from: data)
                success(songsJSON)
            }catch {
                failure(error)
            }
        }
        task.resume()
        
    }
    
    
    
    
    
    
    //MARK: - Activate scheduled Room
    func ActivateRoom(roomId:String,success: @escaping(_ data: String)-> (),failure: @escaping(_ error: Error)->()){
        let url = Constants.APIUrls.ActivateRoom
        var request = URLRequest(url: URL(string: "\(url)\(roomId)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Activation Error>>>>>>>>>>>\(error)")
                failure(error as! Error)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            print("Activation Response >>>>>>>>>>>\(String(data: data, encoding: .utf8)!)")
            success("Session Started.")
        }
        task.resume()
        
    }
    
    
    func sendInvite(username: String, params:[String:String],success:@escaping(_ data:Bool)->(), failure:@escaping(_ error: Error)->()){
        let rawJSON = try? JSONSerialization.data(withJSONObject: params)
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/rooms/invite")!,timeoutInterval: Double.infinity)
        request.addValue(username, forHTTPHeaderField: "username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = rawJSON

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
              failure(error!)
            return
          }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200{
                    success(true)
                }else{
                    success(false)
                }
            }
        }
        task.resume()
    }
    
 
    func getAttendeeFor(room:String,Success:@escaping(_ data:[Attendee])->(),failure:@escaping(_ error : Error)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/rooms/attendees/\(room)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
              failure(error as! Error)
            return
          }
            do {
                let members = try JSONDecoder().decode(MembersModel.self, from: data)
                Success(members.attendees)
            }catch let err {
                failure(error as! Error)
            }
        }
        task.resume()
    }
    
}
