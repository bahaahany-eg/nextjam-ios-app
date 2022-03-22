//
//  UIImage.swift
//  NextJAM
//
//  Created by apple on 10/09/21.
//

import Foundation
import UIKit

extension UIImageView {
    //    MARK: - Check if image has any image or empty...
    public var hasContent: Bool {
        let cgImage = self.image?.cgImage
        let ciImage = self.image?.ciImage
        return cgImage != nil || ciImage != nil
    }
    
    /// Load image from url
    func fetchUserImage(imageUrl: String){
        
        guard let url = URL(string: imageUrl) else { return }
        let data = try? Data(contentsOf: url)
        guard let imageData = data else { return }
        self.image = UIImage(data: imageData)
    }
    
    //MARK: - Fetch image from URL
    func imageFromServerURL(imageName: String, PlaceHolderImage:UIImage) {
        
        if self.image == nil{
            self.image = PlaceHolderImage
        }
        let urlString = "\(Constants.APIUrls.baseUrl)resources/\(imageName)"
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
    
    
    //MARK: -Convert Image to Base 64 String
    func ConvertImageToBase64String() -> String {
        return self.image?.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
    
    //MARK: - Convert Base 64 String To Imgage
    func ConvertBase64ToImage(imageBase64String:String){
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        self.image = image!
    }
    
    
    
    func resizeByByte(maxByte: Int, completion: @escaping (Data) -> Void) {
        var compressQuality: CGFloat = 1
        var imageData = Data()
        var imageByte = self.image?.jpegData(compressionQuality: 1)?.count
        
        while imageByte! > maxByte {
            imageData = (self.image?.jpegData(compressionQuality: compressQuality)!)!
            imageByte = (self.image?.jpegData(compressionQuality: compressQuality)?.count)!
            compressQuality -= 0.1
        }
        
        if maxByte > imageByte! {
            completion(imageData)
        } else {
            completion((self.image?.jpegData(compressionQuality: 1)!)!)
        }
    }
    
}

