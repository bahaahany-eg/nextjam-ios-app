//
//  FAQVC.swift
//  NextJAM
//
//  Created by apple on 18/11/21.
//

import UIKit

class FAQVC: UIViewController{

    @IBOutlet weak var faqTBL: UITableView!
    
    var FAQs = [FAQ]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.faqTBL.delegate = self
        self.faqTBL.dataSource = self
        self.faqTBL.rowHeight = UITableView.automaticDimension;
        getFAQs()
    }
    
    //MARK: - Fetch FAQ and show them to the tableView
    
    func getFAQs(){
        WebLayerUserAPI().getFAQ { data in
            print(data)
            DispatchQueue.main.async {
                self.FAQs = data
                self.faqTBL.reloadData()
            }
        } failure: { error in
            print(error)
        }

    }
    
    
}
extension FAQVC :  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FAQs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as? FAQCell else{ return UITableViewCell.init() }
        cell.title.text = self.FAQs[indexPath.row].question
        cell.anslbl.attributedText = self.FAQs[indexPath.row].answer.htmlToAttributedString
        cell.anslbl.textColor = .white
        return cell
    }
    



}
