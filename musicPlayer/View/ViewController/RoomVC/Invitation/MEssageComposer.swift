//
//  MEssageComposer.swift
//  NextJAM
//
//  Created by apple on 25/11/21.
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    public let textMessageRecipients = [String]() // For pre-populating the recipients list (optional, depending on your needs)

    func canSendText() -> Bool {return MFMessageComposeViewController.canSendText()}

    func ConfigureMessageViewController(username:String,number:String)->MFMessageComposeViewController{
        let ComposeVC = MFMessageComposeViewController()
        
        ComposeVC.messageComposeDelegate = self
        ComposeVC.recipients = nil
        if number.isValidPhoneNumber(){
//            ComposeVC.recipients = [number]
//            ComposeVC.s
        }else{
            ComposeVC.recipients = nil
        }
//        ComposeVC.recipients = ["+13479016444"] //number.count > 1 ? [number] : nil
        
        ComposeVC.body = "Your have been invited to join NextJam by \(username)\nClick the link below to download the app: https://testflight.apple.com/join/sYqnvlV4"
        return ComposeVC
    }
        
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}
