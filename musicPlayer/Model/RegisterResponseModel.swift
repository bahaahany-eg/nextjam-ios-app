//
//  RegisterResponseModel.swift
//  musicPlayer
//
//  Created by apple on 19/08/21.
//

import Foundation


// MARK: - RegisterResponce
struct RegisterResponceModel: Decodable {
    let jsonWebToken: String?
    let resetToken: String?

    enum CodingKeys: String, CodingKey {
        case jsonWebToken = "json_web_token"
        case resetToken = "reset_token"
    }
}
