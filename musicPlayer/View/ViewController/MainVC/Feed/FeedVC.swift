
import UIKit


class FeedVC: UIViewController,UITextViewDelegate{
    
    @IBOutlet weak var emailTF: RoundTextField!
//    {
//        didSet{
//            emailTF.attributedPlaceholder = NSAttributedString(string: "Email...", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3764821291, green: 0.4897046685, blue: 0.5447942019, alpha: 1) ])
//        }
//    }
    @IBOutlet weak var fnameTf: RoundTextField!
//    {
//        didSet{
//            fnameTf.attributedPlaceholder = NSAttributedString(string: "First name", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3764821291, green: 0.4897046685, blue: 0.5447942019, alpha: 1) ])
//        }
//    }
    
    @IBOutlet weak var LnameTF: RoundTextField!
//    {
//        didSet{
//            LnameTF.attributedPlaceholder = NSAttributedString(string: "Last name", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3764821291, green: 0.4897046685, blue: 0.5447942019, alpha: 1) ])
//        }
//    }
    
    @IBOutlet weak var feedbackTV: UITextView!{
        didSet{
            feedbackTV.text = "Enter you message..."
            feedbackTV.textColor =  #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7)
        }
    }
    
    @IBOutlet weak var sendFeedbck: UIButton!{
        didSet{
            sendFeedbck.MakeRound()
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return  .lightContent
        } else {
            return .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedbackTV.delegate = self
    }
    
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendFBAction(_ sender: UIButton) {
        
        if isValidEmail(self.emailTF.text!){
            validateName() ? sendFB(send:true): sendFB(send: false)
        }else{
            self.showAlert(title: "Error", msg: "Enter a valid email.")
        }
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter you message..." {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter you message..."
            textView.textColor =  #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7)
        }
    }
    
    func resetUI(){
        DispatchQueue.main.async{ self.fnameTf.text = ""
            self.emailTF.text = ""
            self.LnameTF.text = ""
            self.feedbackTV.text = "Enter you message..."
            self.feedbackTV.textColor =  #colorLiteral(red: 0.6, green: 0.1699213684, blue: 0.3734838367, alpha: 0.7)
        }
    }
    
    
    func sendFB(send:Bool){
        if !send{
            self.showAlert(title: "Error", msg: "Check fields and try again.")
        }else{
            guard let fn = self.fnameTf.text else{ return }
            guard let ln = self.LnameTF.text else{ return }
            guard let email = self.emailTF.text else{ return }
            guard let msg = self.feedbackTV.text else{ return }
            let params = [
                "email":email,
                "first_name":fn,
                "last_name":ln,
                "message":msg]
            WebLayerUserAPI().sendFeedback(parameters: params) { data in
                self.showAlert(title: "Success", msg: data)
                self.resetUI()
            } failure: { error in
                self.showAlert(title: "Failure", msg: error.localizedDescription)
            }

        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validateName() -> Bool{
        guard let fn = self.fnameTf.text else { return false }
        guard let ln = self.LnameTF.text else { return false }
        
        if fn.isEmpty || ln.isEmpty {
            return false
        }else{
            return true
        }
    }
    
    func showAlert(title:String,msg:String){
        let alert = UIAlertController(title: title, message:msg , preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension FeedVC {
    
    func setupUI(){
        self.feedbackTV.layer.borderColor = UIColor(named: "JAM")!.cgColor
        self.feedbackTV.layer.cornerRadius = 27
    }
}
