//
//  UIimagePickerControlleExtension.swift
//  NextJAM
//
//  Created by apple on 10/09/21.
//

import Foundation
import UIKit
import AVFoundation
import Photos

protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool,
                     to sourceType: UIImagePickerController.SourceType)
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage)
    func cancelButtonDidClick(on imageView: ImagePicker)
}

class ImagePicker: NSObject {

    private weak var controller: UIImagePickerController?
    weak var delegate: ImagePickerDelegate? = nil

    func dismiss() { controller?.dismiss(animated: true, completion: nil) }
    func present(parent viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = sourceType
            self.controller = controller
            viewController.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: Get access to camera or photo library
extension ImagePicker {

    private func showAlert(targetName: String, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertVC = UIAlertController(title: "Access to the \(targetName)",
                                            message: "Please provide access to your \(targetName)",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                guard   let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                        UIApplication.shared.canOpenURL(settingsUrl) else { completion?(false); return }
                UIApplication.shared.open(settingsUrl, options: [:]) { [weak self] _ in
                    self?.showAlert(targetName: targetName, completion: completion)
                }
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion?(false) }))
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?
                .rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }

    func cameraAsscessRequest() {
        if delegate == nil { return }
        let source = UIImagePickerController.SourceType.camera
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            delegate?.imagePicker(self, grantedAccess: true, to: source)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.delegate?.imagePicker(self, grantedAccess: granted, to: source)
                } else {
                    self.showAlert(targetName: "camera") { self.delegate?.imagePicker(self, grantedAccess: $0, to: source) }
                }
            }
        }
    }

    func photoGalleryAsscessRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            guard let self = self else { return }
            let source = UIImagePickerController.SourceType.photoLibrary
            if result == .authorized {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.imagePicker(self, grantedAccess: result == .authorized, to: source)
                }
            } else {
                self.showAlert(targetName: "photo gallery") { self.delegate?.imagePicker(self, grantedAccess: $0, to: source) }
            }
        }
    }
}

// MARK: UINavigationControllerDelegate

extension ImagePicker: UINavigationControllerDelegate { }

// MARK: UIImagePickerControllerDelegate

extension ImagePicker: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            let assetPath = info[UIImagePickerController.InfoKey.referenceURL.rawValue] as! NSURL
            if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                print("JPG")
                delegate?.imagePicker(self, didSelect: image)
                return
            }
            else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                print("PNG")
                delegate?.imagePicker(self, didSelect: image)
                return
            }
            else if (assetPath.absoluteString?.hasSuffix("GIF"))! {
                print("GIF")
                delegate?.imagePicker(self, didSelect: image)
                return
            }
            else {
                print("Unknown")
                return
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
                if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                    print("JPG")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                    print("PNG")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else if (assetPath.absoluteString?.hasSuffix("GIF"))! {
                    print("GIF")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else {
                    print("Unknown")
                    return
                }
            }
            return
        }

        if let image = info[.originalImage] as? UIImage {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
                if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                    print("JPG")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                    print("PNG")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else if (assetPath.absoluteString?.hasSuffix("GIF"))! {
                    print("GIF")
                    delegate?.imagePicker(self, didSelect: image)
                    return
                }
                else {
                    print("Unknown")
                    return
                }
            }
        } else {
            print("Other source")
        }
    }
    func fromHeicToJpg(heicPath: String, jpgPath: String) -> UIImage? {
        let heicImage = UIImage(named:heicPath)
        let jpegImageData = heicImage?.jpegData(compressionQuality: 0.5)!
        FileManager.default.createFile(atPath: jpgPath, contents: jpegImageData, attributes: nil)
        let jpgImage = UIImage(named: jpgPath)
        return jpgImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.cancelButtonDidClick(on: self)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
      let scale = newWidth / image.size.width
      let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
}
