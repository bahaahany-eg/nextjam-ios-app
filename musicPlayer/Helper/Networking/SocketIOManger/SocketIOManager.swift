//
//  SocketIOManager.swift
//  SocketIOManager
//
//  Created by apple on 20/08/21.
//

import Foundation
import SocketIO
import UserNotifications
import UniformTypeIdentifiers


class SocketIOManager : NSObject {
    static let sharedInstance = SocketIOManager()
    static let manager = SocketManager(socketURL: URL(string:"wss://socket.nextjam.app/room")! ,config: [.log(true), .compress])
    
    var socket: SocketIOClient = manager.defaultSocket
    
    override init() {
        super.init()
        self.setupHandlers()
        self.socket = SocketIOManager.manager.socket(forNamespace: "/room")
        
        socket.on(clientEvent: .connect) { data, ack in
            print("===== SOCKET CONNECTED =====")
        }
        socket.on(clientEvent: .disconnect) { data, ack in
            print("===== Socket Disconnected =====")
        }
    }
    
    //MARK: - Connect Socket
    func establishConnection(){
        self.socket.connect(timeoutAfter: 10000) {
            print("*****TimeOut*****")
        }
        
        self.socket.on("connect"){ data, ack in
            print("socket connected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "connectionStatus"), object: true)
        }
        self.socket.on("disconnect"){ data, ack in
            print("socket disconnect")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "connectionStatus"), object: false)
            self.socket.connect()
        }
        self.socket.on("connect_error"){ data, ack in
            print("socket connect_error")
            self.socket.manager?.reconnect()
        }
        self.socket.on("connect_timeout"){ data, ack in
            print("socket connect_timeout")
            self.socket.manager?.reconnect()
        }
        self.socket.connect()
        print("=========SOCKET.CONNECT CALLED=========")
        
    }
    //MARK: - Disconnect Socket
    func dicsonnectSocket(){
        socket.disconnect()
    }
    
    
    //MARK: - Connecting user with the socket
    func connectToServerWithNickName(nickName:String,inviteCode: String, completionHandler: @escaping (_ userList: String)->Void) {
        print("inside the connect to server function")
        let Dict = ["invite_code":inviteCode,
                    "guest":nickName]
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(Dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                print(jsonString)
                socket.emit("join_room",jsonString)
                print("join Room Emitted")
            }
        }
        
    }
    
    //MARK: -Exit from the Socket Room
    func exitFromSocketWithNickName(nickname: String,roomid:String, completionHandler: ()->Void) {
        let Dict = ["room_id":roomid]
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(Dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                
                socket.emit("close_room", jsonData as! SocketData)
                completionHandler()
                print("join Room Emitted")
            }
        }
    }
    
    //MARK: - Add music to Playlist..
    /**At the moment we are usign music_search event to emit song to the socket that will be listen by th music_search event listner and will be added to the playlist.*/
    func addMusic(song: String,roomId: String,playlistId:String,completionHandler: @escaping (_ songResponse: Data) -> Void){
        let Dict = ["room_id":roomId,
                    "song_title":song,
                    "playlistId":playlistId]
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try? encoder.encode(Dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                print("JSON is : \(jsonString)")
                socket.emit("music_add",jsonString)
                print("music add Emitted")
            }
        }
    }
    //MARK: - Emit Event to add Song to Playlist
    /**
     This event is user to fire details of song user wants to add in the playlist from searching apple musci api for a particular room.
     # Lists
     
     Required arguments by this function:
     1. username: String
     2. song : String
     3. songImage : String
     4. type : String default is "Song"
     5. artistName : String
     6. name : String
     7. inviteCode : String
     */
    func searchForSongOverSocket(username: String, song:String, songImage: String, type:String, artistName:String, name:String, inviteCode:String, completionHandler: @escaping (_ songResponse: Data) -> Void){
        let Dict = ["song_title":song,
                    "image_url":songImage,
                    "type":type,
                    "invite_code": inviteCode,
                    "artist_name":artistName,
                    "name":name,
                    "username": username]
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(Dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8){
                print("JSON is \(jsonString)")
                socket.emit("music_search", jsonString)
                print("music_search emitted")
            }
        }
        
    }
    //MARK: - Update now Playing song on guest side
    /**
     This event is user to fire details of now playing song for a particular room to the members of that room.
     # Lists
     
     Required arguments by this function:
     
     1. songId: String
     2. inviteCode : String
     3. songName : String
     */
    func updateNowPlayingSongs(songID: String, inviteCode:String, songName:String, completionHandler: @escaping(_ updateResponse: Data)->Void){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        let dict = ["invite_code":inviteCode,
                    "song_name": songName,
                    "song_title":songID,
                    "username":username ]
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8){
                print(jsonString)
                socket.emit("update_currently_playing",jsonString)
                print("update now playing song is emitted.")
            }
        }
    }
    func notifyForSongDeletion(invitationCode:String){
        let dict = [ "invite_code": invitationCode]
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8){
                print(jsonString)
                socket.emit(("delete_song"), jsonString)
                print("Song Delete Event Emmited")
            }
        }
    }
    
    func leaveRoomFromSocket(invitationCode: String,completionHandler: @escaping (_ status: Data) -> Void){
        guard let username = Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String else { return }
        let dict = [ "invite_code": invitationCode,
                     "username":username]
        let encoder = JSONEncoder()
        do {
            let jsonData = try? encoder.encode(dict)
            if let jsonString = String(data: jsonData!, encoding: .utf8){
                print(jsonString)
                socket.emit(("leave_room"), jsonString)
                print("leave_room Event Emmited")
            }
            
        }
    }
    
    
    
    //MARK: - Add Socket Handlers
    /**
     The setupHandlers method is used to ad handled in the socket manager Class
     */
    func setupHandlers() {
        //MARK: - socket disconnect listener
        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconected")
        }
        //MARK: - new member listener
        socket.on("new_member") { data, ack in
            print("new member joined\(data)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchSongfromServer"), object: false)
        }
        //MARK: - add song listener
        socket.on("addsong") { data, ack in
            print("song added response from socket \(data)")
            print("ack \(ack)")
        }
        
        socket.on("music_search") { data, ack in
            print(data)
        }
        socket.on("music_add") { data, ack in
            print(data)
        }
        //MARK: - Current playing song event listner
        socket.on("update_currently_playing"){data, ack in
            print(data)
        }
        socket.on("close_room") { data, ack in
            print(data)
        }
        socket.on("leave_room") { data, ack in
            print(data)
        }
        socket.on("delete_song") { data, ack in
            print(data)
        }
        
    }
    
}



