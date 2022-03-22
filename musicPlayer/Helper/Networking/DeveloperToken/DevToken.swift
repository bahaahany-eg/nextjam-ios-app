//
//  DevToken.swift
//  NextJAM
//
//  Created by apple on 01/11/21.
//

import UIKit
import CryptoKit

struct Payload: Encodable {
    let iss = "3AXPA6WL7G"
    let exp = Date().timeIntervalSinceNow + 10000 * 60
    let aud = "appstoreconnect-v1"
}


struct Header: Encodable {
    let kid = "DVU245PT8H"
    let alg = "ES256"
}

class GenerateToken {
    
    
    func getToken() ->String {
        let secret = """
    MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg3eNVRysNlDJizIsN
    SGNgfk7pXagyz0I4tA+0HFu0vXGgCgYIKoZIzj0DAQehRANCAASqxW9vwj7GBKJs
    oh5YmFeaV59Cd1734DpMugw9ZRKYE+nSDhjicZ58hvcWKwvs3JI/pk6yQMxlPE7J
    nLYKNS5q
    """
        
        let privateKey = SymmetricKey(data: secret.data(using: .utf8)!)
        
        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()
        
        let payloadJSONData = try! JSONEncoder().encode(Payload())
        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()
        
        let toSign = (headerBase64String + "." + payloadBase64String).data(using: .utf8)!
        
        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()
        
        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        print(token)
        return token
    }
    
}
