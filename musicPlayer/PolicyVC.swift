//
//  PolicyVC.swift
//  NextJAM
//
//  Created by apple on 15/11/21.
//

import UIKit

class PolicyVC: UIViewController {

    @IBOutlet weak var lbl: UITextView!
    var ttl = ""
    var policy = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ttl
        self.lbl.isEditable = false
        policy ? loadPolicy() : loadTermOfServices()
    }
    
    @IBAction func bckAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Fetch Policy and show them to the user
    func loadPolicy(){
        WebLayerUserAPI().privacyPolicy { data in
            DispatchQueue.main.async {
                self.lbl.attributedText = data
                self.lbl.textColor = .white
            }
        } failure: { error in
            print(error.localizedDescription)
        }

    }
    //MARK: -Fetch Term of services and show them to the user
    func loadTermOfServices(){
        WebLayerUserAPI().termOfService { data in
            DispatchQueue.main.async {
                self.lbl.attributedText = data
                self.lbl.textColor = .white
            }
        } failure: { error in
            print(error.localizedDescription)
        }

    }
}
