//
//  LoginViewController
//  OnTheMap
//
//  Created by Joshua Schindler on 10/8/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextViewDelegate {
    let textDelegate = TextDelegate()
    
    @IBOutlet weak var TextFieldID: UITextField!
    @IBOutlet weak var TextFieldPassword: UITextField!
    @IBOutlet weak var LabelMessage: UILabel!
    @IBOutlet weak var TextViewNoAccount: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextFieldID.delegate = textDelegate
        self.TextFieldPassword.delegate = textDelegate
        
        // You must set the formatting of the link manually
        let linkAttributes = [
            NSLinkAttributeName: NSURL(string: "https://www.udacity.com")!,
            NSForegroundColorAttributeName: UIColor.blue
            ] as [String : Any]
        
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign up")
        
        // Set the 'click here' substring to be the link
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(23, 7))
        
        self.TextViewNoAccount.delegate = self
        self.TextViewNoAccount.attributedText = attributedString
    }  

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    @IBAction func uLogin(_ sender: Any) {
        var strMessage: String = ""
        if TextFieldID.text == "" {
            strMessage = "ID is required"
        }
        if TextFieldPassword.text == "" {
            strMessage = strMessage + "\nPassword is required"
        }
        
        if strMessage == "" {
            logIn(strID: TextFieldID.text!, strPassword: TextFieldPassword.text!)
        } else {
            LabelMessage.text = strMessage
        }
    }

    private func logIn(strID: String, strPassword: String) {
        LabelMessage.text = "Logging in, please wait..."
        let _ = SIClient.sharedInstance.logIn(strID: strID, strPassword: strPassword) { (studentData, error) in
            if error == nil {
                let controller: UITabBarController
                controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                performUIUpdatesOnMain {
                    self.present(controller, animated:true, completion:nil)
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "There was a problem logging in!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        /*loginButton.isEnabled = enabled
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }*/
    }
    
    func displayError(_ errorString: String?) {
        /*if let errorString = errorString {
            debugTextLabel.text = errorString
        }*/
    }
    
    func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}
