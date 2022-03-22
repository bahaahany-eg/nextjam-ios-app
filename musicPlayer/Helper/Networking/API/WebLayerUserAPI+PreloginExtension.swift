//
//  WebLayerUserAPI+PreloginExtension.swift
//  NextJAM
//
//  Created by apple on 11/11/21.
//

import Foundation

//MARK: -Prelogin API Extension for WebLayerUserAPI
extension WebLayerUserAPI{

    //MARK: - Register API
    func registerUser(url: URL,parameters: [String:Any],success : @escaping(_ data: RegisterResponceModel) -> (),failure: @escaping(_ error: Error) -> ()){
        let rawJSON = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        print("parameter:\(parameters)")
        print("JSON:\(rawJSON)")
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = rawJSON
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let registerSuccess = try JSONDecoder().decode(RegisterResponceModel.self, from: data)
                success(registerSuccess)
            }catch {
                failure(error)
            }
        }
        task.resume()
    }
    
    //MARK: - Login API
    func loginUser(url: URL,parameters: [String:Any],success : @escaping(_ data: LoginResponceModel) -> (),failure: @escaping(_ error: Error) -> ()) {
        let rawJSON = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = rawJSON
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let loginSuccess = try JSONDecoder().decode(LoginResponceModel.self, from: data)
                success(loginSuccess)
            } catch {
                failure(error)
            }
        }
        task.resume()
        
    }
    
    func getOTP(phone:String){
        var request = URLRequest(url: URL(string: "\(Constants.APIUrls.baseUrl)users/otp/\(phone)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    
    
    //MARK: -Logout API
    func logOut(username:String,success:@escaping( _ Response:String)-> (), failure: @escaping( _ error: Error)-> ()){
        
        var request = URLRequest(url: URL(string: Constants.APIUrls.logout)!,timeoutInterval: Double.infinity)
        request.addValue("\(username)", forHTTPHeaderField: "username")
        
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                failure(error as! Error)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            success(String(data: data, encoding: .utf8) ?? "inside logout success block")
        }
        task.resume()
    }
    
    //MARK: - Check Phone number...
    func ValidataPhoneNumber(number:String, Success:@escaping(_ data:Bool)->(), failure:@escaping(_ error:Error)-> ()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/users/phonenumber-availability/\(number)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            if let response  = response as? HTTPURLResponse {
                let status = response.statusCode
                if status == 404 {
                    Success(false)
                }else if status == 200 {
                    Success(true)
                }
            }else {
                failure(error!)
            }
            
        }
        task.resume()
        
    }
    
    func verifyOTP(forPhone:String, otp:String,success:@escaping(_ status: Bool,_ message: String)->()){
        var request = URLRequest(url: URL(string: "https://test.nextjam.app/api/users/verify/\(otp)")!,timeoutInterval: Double.infinity)
        request.addValue(forPhone, forHTTPHeaderField: "phonenumber")
        request.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                success(false, error!.localizedDescription)
                return
            }
            if let res = response as? HTTPURLResponse {
                switch res.statusCode{
                case 200,201 :
                    success(true,"Success: Otp Verified Successfully")
                    break
                case 400,401:
                    success(false,"Error : Invalid verification code")
                    break
                default:
                    success(false, "")
                    break
                }
            }else{
                success(false, "Couldn't parse the response.")
            }
        }
        task.resume()
    }
    
    func fetchImage(url:String,image:@escaping(_ image:Data)->()){
        var request = URLRequest(url: URL(string:url)!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            if data != nil {
                image(data)
            }
        }

        task.resume()
    }
    
    
    
}
