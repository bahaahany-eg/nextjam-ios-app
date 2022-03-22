//
//  Constants.swift
//  musicPlayer
//
//  Created by apple on 19/08/21.
//

import Foundation
import SocketIO
import GoogleSignIn

struct Constants {
    
    struct Shared {
        var songArray = [SongDetails]()
        
        func getSongsArray()->[SongDetails]{
            return songArray
        }
        
        mutating func AddSongstoArray(song : SongDetails){
            songArray.append(song)
        }
    }
    
    let token                       = ""
    struct APIUrls {
        static let baseUrl          = "https://test.nextjam.app/api/"
        static let registerUrl      = baseUrl + "users/register"
        static let loginURL         = baseUrl + "users/login"
        static let logout           = baseUrl + "users/logout"
        static let updateProfile    = baseUrl + "users"
        static let createRoom       = baseUrl + "rooms/create"
        static let FCMToken         = baseUrl + "users/fcm"
        static let PopularUser      = baseUrl + "users/popular-users"
        static let FollowUser       = baseUrl + "users/follow-user"
        static let GetAllRooms      = baseUrl + "rooms/all"
        static let GetSesssionSongs = baseUrl + "rooms/songs/"
        static let ActivateRoom     = baseUrl + "rooms/activate/"
        static let SearchQuery      = baseUrl + "rooms/search"
//        rooms/attendees
        static let GetImage         = baseUrl + "resources/"
        static let GetUserSessions  = baseUrl + "users/rooms"
        static let Follow           = baseUrl + "users/follow"
        static let UnFollow         = baseUrl + "users/unfollow"
        static let GetFollowers     = baseUrl + "users/followers"
        static let FAQ              = baseUrl + "faq"
        static let CheckNumberAvailability = baseUrl + "users/phonenumber-availability/"
        static let DeleteRoom       = baseUrl + "rooms/"
        static let Resources        = baseUrl + "resources/"
    }
    
    struct staticKeys {
        static let USER_DEFAULTS        = UserDefaults.standard
        static let FCMtoken             = "FCMtoken"
        static let roomID               = "roomID"
        static let roomName             = "roomName"
        static let invitationCode       = "invitationCode"
        static let nickname             = "nickname"
        static let playlistdata         = "playlistdata"
        static let UserRole             = "userRole"
        static let LoggedInStatus       = "loggedIn"
        static let DeveloperToken       = "Token"
        
    }
    
    
    struct UserDetails {
        static let phoneNumber          = "phoneNumber"
        static let UserName             = "userName"
        static let DisplayName          = "displayName"
        static let imageUrl             = "imageUrl"
    }
    
    struct Config {
        
        static let signInConfig =  "893675029309-mbp3gaqp3ditp0ngi3sbm62dues7uubu.apps.googleusercontent.com"
    }
    
}





