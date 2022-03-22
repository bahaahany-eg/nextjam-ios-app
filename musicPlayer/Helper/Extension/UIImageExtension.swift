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
        if imageName != ""{
            if self.image == nil{
                self.image = PlaceHolderImage
            }
            let urlString = "\(Constants.APIUrls.baseUrl)resources/\(imageName)"
            URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    //                    print(error ?? "No Error")
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    if let d = data {
                        let image = UIImage(data: d)?.jpegData(compressionQuality: 0.2)
                        self.image = UIImage(data: image ?? Data())
                    }else{
                        self.image = PlaceHolderImage
                    }
                })
                
            }).resume()
        }else{
            self.image = PlaceHolderImage
        }
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
    
    
    
    //MARK: - download image
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    //    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: ((UIImage) -> Void)?) {
    //        guard let url = URL(string: link) else { return }
    ////        downloaded(from: url, contentMode: mode, completion: completion)
    //    }
    
    
}




class CustomImageView: UIImageView {
    
    private let imageCache = NSCache<AnyObject, UIImage>()
    
    func ImageLoader(fromURL imageURL: URL, placeHolderImage: UIImage){
        self.image = placeHolderImage
        
        if let cachedImage = self.imageCache.object(forKey: imageURL as AnyObject){
            //            debugPrint("image loaded from cache for =\(imageURL)")
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            [weak self] in
            
            if let imageData = try? Data(contentsOf: imageURL){
                //                debugPrint("image downloaded from server...")
                if let image = UIImage(data: imageData){
                    DispatchQueue.main.async {
                        self?.imageCache.setObject(image, forKey: imageURL as AnyObject)
                        self?.image = image
                    }
                }
            }
        }
    }
}



