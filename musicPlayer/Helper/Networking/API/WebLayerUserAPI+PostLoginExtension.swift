//
//  WebLayerUserAPI+PostLoginExtension.swift
//  NextJAM
//
//  Created by apple on 11/11/21.
//

import Foundation
import Alamofire

//MARK: - Post Login App General API

extension WebLayerUserAPI{
    
    
    //MARK: - Save FCM To Server API
    func saveFCMToServer(url:URL, parameters: [String: String],success : @escaping(_ data : Bool) -> (), failure : @escaping(_ error: Error) -> ()) {
        let semaphore = DispatchSemaphore(value: 0)
        let rawJSON = try? JSONSerialization.data(withJSONObject: parameters)
        var request  = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = rawJSON
        request.addValue(Constants.staticKeys.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as? String ?? "", forHTTPHeaderField: "username")
        
        let task = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            print(String(data: data,encoding: .utf8)!)
            /// Decode data here to verify if token saved successfully.
            if error == nil {
                success(true)
            } else {
                failure(error!)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    
    //MARK: - Fetch user session list by username
    func fetchSessionForUser(with username:String,success:@escaping(_ data:GetAllSessionModel)->(), failure:@escaping(_ error:Error)->()){
        let page = 1
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.GetUserSessions)?page=\(page)&limit=10")!,timeoutInterval: Double.infinity)
        request.addValue("\(username)", forHTTPHeaderField: "username")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let userSessions = try JSONDecoder().decode(GetAllSessionModel.self, from: data)
                success(userSessions)
            }catch let error{
                failure(error)
            }
        }
        task.resume()
        
    }
    //MARK: - Search Field api
    func search(with Query:String,page:String,success: @escaping(_ data:GetAllSessionModel)->(),failure: @escaping(_ error: Error)->()){
        let query = Query.replacingOccurrences(of: " ", with: "+")
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.SearchQuery)?query=\(query)&page=\(page)&limit=10")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let searchResult = try JSONDecoder().decode(GetAllSessionModel.self, from: data)
                success(searchResult)
            }catch let error{
                failure(error)
            }
        }
        task.resume()
    }
    
    //MARK: - Fetch Popular Users List API
    func FethcPopularUser(page: Int, success: @escaping(_ data: PopularUserResponse) -> (), failure : @escaping(_ error: Error) -> ()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/users/popular?page=\(page)&limit=20")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let userlist = try JSONDecoder().decode(PopularUserResponse.self, from: data)
                success(userlist)
            }catch {
                failure(error)
            }
        }
        task.resume()
    }
    
    
    
    /*{
        let url = Constants.APIUrls.PopularUser
        var request = URLRequest(url: URL(string: "\(url)?page=\(page)&limit=20")!,timeoutInterval: Double.infinity)
//        request.addValue(username, forHTTPHeaderField: "username")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let userlist = try JSONDecoder().decode(PopularUserResponse.self, from: data)
                success(userlist)
            }catch {
                failure(error)
            }
            
        }
        task.resume()
        
    }*/
    
    
    //MARK: - Follow User API
    func FollowUser(Following:String, username: String, success: @escaping(_ _data:FollowUserResponse) -> (), failure: @escaping(_ error: Error) -> ()){
        
        let parameters = ["user": Following]
        let rawJSON = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: URL(string: "")!,timeoutInterval: Double.infinity)
        request.addValue("\(username)", forHTTPHeaderField: "username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = rawJSON
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    //MARK: - Get All Session Api
    func getAllSession(usrname: String,page:Int, Success: @escaping(_ data: GetAllSessionModel) -> () , failure: @escaping(_ error: Error) -> ()){
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.GetAllRooms)?page=\(page)&limit=10")!,timeoutInterval: Double.infinity)
        print("URL IS: \(URL(string: "\(Constants.APIUrls.GetAllRooms)?page=\(page)&limit=10"))")
        request.addValue("\(usrname)", forHTTPHeaderField: "username")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            do {
                print(String(data: data, encoding: .utf8)!)
                let responseData = try JSONDecoder().decode(GetAllSessionModel.self, from: data)
                Success(responseData)
            } catch {
                failure(error)
            }
        }
        task.resume()
    }
    
    
    //MARK: - get user Profile by username
    func getProfile(of:String,forUser:String,success:@escaping(_ data: UserProfileModel)->(),failure: @escaping(_ error:Error)->()){
        let urlString = "\(Constants.APIUrls.baseUrl)users/\(of)".replacingOccurrences(of: " ", with: "%20")
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("\(forUser)", forHTTPHeaderField: "username")
        print("profile for: ",forUser)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do{
                let profile = try JSONDecoder().decode(UserProfileModel.self, from: data)
                success(profile)
            }catch let err {
                failure(err)
            }
        }
        task.resume()
    }
    
    
    func followed(User:String, byUser:String,Success: @escaping(_ data: Bool)->(), failure: @escaping(_ err: Error)->()){
        guard let url = URL(string: "\(Constants.APIUrls.Follow)?username=\(User)".replacingOccurrences(of: " ", with: "%20")) else {
            return
        }
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("\(byUser)", forHTTPHeaderField: "username")
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            if let response  = response as? HTTPURLResponse {
                if response.statusCode == 200 || response.statusCode == 400{
                    Success(true)
                }else{
                    Success(false)
                }
            }
        }
        task.resume()
    }
    
    
    func Unfollow(user:String, byUser:String,Success: @escaping(_ data : Bool)->(),failure:@escaping(_ err : Error)->()){
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.UnFollow)?username=\(user)".replacingOccurrences(of: " ", with: "%20"))!,timeoutInterval: Double.infinity)
        request.addValue("\(byUser)", forHTTPHeaderField: "username")
        
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            if let response = response as? HTTPURLResponse{
                if response.statusCode == 200 || response.statusCode == 400{
                    Success(true)
                }else{
                    Success(false)
                }
            }
        }
        task.resume()
    }
    func getFollower(for User:String,page:Int,success:@escaping(_ data:FollowersModel)->(),failure:@escaping(_ erro: Error)->()){
        let urlString = "\(Constants.APIUrls.GetFollowers)?username=\(User)&page=\(page)&limit=10".replacingOccurrences(of: " ", with: "+")
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do{
                let followers = try JSONDecoder().decode(FollowersModel.self, from: data)
                success(followers)
            }catch let err{
                failure(err)
            }
        }
        task.resume()
    }
    
    
    func sendFeedback(parameters:[String:String],success:@escaping(_ Msg: String)->(), failure: @escaping(_ error: Error)->()){
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: parameters,
            options: .prettyPrinted),let theJSONText = String(data: theJSONData,encoding: String.Encoding.utf8) {
            print("JSON string = \n\(theJSONText)")
            let postData = theJSONText.data(using: .utf8)
            var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/feedback")!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    failure(error!)
                    return
                }
                if let response  = response as? HTTPURLResponse {
                    if response.statusCode == 200{
                        do {
                            let msg = try JSONSerialization.jsonObject(with: data, options: [])
                            success("feedback submitted successfully")
                        }catch let error {
                            failure(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func privacyPolicy(Success: @escaping(_ data:NSAttributedString)->(), failure: @escaping(_ error: Error)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/privacy-policy")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error!)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            do {
                let html = try (JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary)?.value(forKey: "content")!
                let h = html as! String
                
                Success(h.htmlToAttributedString!)
            }catch let error{
                print(error)
                failure(error)
            }
        }
        task.resume()
    }
    
    func termOfService(Success: @escaping(_ data:NSAttributedString)->(), failure: @escaping(_ error: Error)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/terms-of-service")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
              failure(error!)
            return
          }
            do{
                let html = try (JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary)?.value(forKey: "content")!
                let h = html as! String
                
                Success(h.htmlToAttributedString!)
            }catch let error{
                print(error)
                failure(error)
            }
        }

        task.resume()
        

    }

    
    func getFAQ(success: @escaping(_ data: [FAQ])->(), failure: @escaping(_ error: Error)-> ()){
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.FAQ)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let d = data else {
              failure(error!)
            return
          }
            print(String(data: d,encoding: .utf8)!)
            do {
                let result = try JSONDecoder().decode(FAQModel.self, from: d)
                success(result.faqs)
                
                /**
                 
 //                let json = (try? JSONSerialization.jsonObject(with: d, options: []) as? NSDictionary)!.value(forKey: "faqs")! as? NSArray)!)
 //                let que = ([0] as! NSDictionary).value(forKey: "question")!
 //                let ans = ((((((try? JSONSerialization.jsonObject(with: d, options: []) as? NSDictionary)!.value(forKey: "faqs")! as? NSArray)!)[0] as! NSDictionary).value(forKey: "answer")! as! String).htmlToAttributedString)
                 */
            }catch let error {
                failure(error)
            }
        }
        task.resume()
        
    }
    
    
    func fetchUserLikedSongs(username: String,success: @escaping(_ data: [likedSong])->(), failure: @escaping(_ error: Error)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/songs/liked?page=1&limit=100")!,timeoutInterval: Double.infinity)
        request.addValue(username, forHTTPHeaderField: "username")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              print(String(describing: error))
              return
          }
          print(String(data: data, encoding: .utf8)!)
            do {
                let s = try JSONDecoder().decode(LikedSongs.self, from: data)
                success(s.songs)
            }catch let err{
             failure(err)
            }
        }
        task.resume()
    }
    
    func LikeSongs(params: [String:String], username:String,success: @escaping(_ data: String)->(), failure: @escaping(_ error: Error)->()){
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: params,
            options: .prettyPrinted),let theJSONText = String(data: theJSONData,encoding: String.Encoding.utf8) {
            print("JSON string = \n\(theJSONText)")
            let postData = theJSONText.data(using: .utf8)
            var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/songs/like/")!,timeoutInterval: Double.infinity)
            request.addValue(username, forHTTPHeaderField: "username")
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    failure(error!)
                    return
                }
                print(String(data: data, encoding: .utf8)!)
            }
            task.resume()
        }
    }
    
    
    func unlikeSong(with id: Int,username: String,success:@escaping(_ data: Bool)->(),failure:@escaping(_ error:Error)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/songs/unlike/\(id)")!,timeoutInterval: Double.infinity)
        request.addValue(username, forHTTPHeaderField: "username")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
              failure(error!)
            return
          }
          print(String(data: data, encoding: .utf8)!)
            if let r = response as? HTTPURLResponse {
                if r.statusCode == 200 {
                    success(true)
                }
            }
        }
        task.resume()

    }
    
    
}
