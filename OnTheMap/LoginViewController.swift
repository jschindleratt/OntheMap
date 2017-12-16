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
    
    @IBOutlet weak var txbID: UITextField!
    @IBOutlet weak var txbPassword: UITextField!
    
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txvNoAccount: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txbID.delegate = textDelegate
        self.txbPassword.delegate = textDelegate
        
        // You must set the formatting of the link manually
        let linkAttributes = [
            NSLinkAttributeName: NSURL(string: "https://www.udacity.com")!,
            NSForegroundColorAttributeName: UIColor.blue
            ] as [String : Any]
        
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign up")
        
        // Set the 'click here' substring to be the link
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(23, 7))
        
        self.txvNoAccount.delegate = self
        self.txvNoAccount.attributedText = attributedString
    }  

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    
    @IBAction func uLogin(_ sender: Any) {
        var strMessage: String = ""
        if txbID.text == "" {
            strMessage = "ID is required"
        }
        if txbPassword.text == "" {
            strMessage = strMessage + "\nPassword is required"
        }
        
        if strMessage == "" {
            logIn(strID: txbID.text!, strPassword: txbPassword.text!)
        } else {
            lblMessage.text = strMessage
        }
    }

    private func logIn(strID: String, strPassword: String) {
        lblMessage.text = "Logging in, please wait..."
        /* 1. Set the parameters         var parametersWithApiKey = parameters
         parametersWithApiKey[ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject?*/

        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(strID)\", \"password\": \"\(strPassword)\"}}".data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String, debugLabelText: String? = nil) {
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                    self.lblMessage.text = error
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }

            /* GUARD: Did we get a successful 2XX response?*/
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                displayError("Your request did not return a status code!")
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                if statusCode == 403 {
                    displayError("Invalid ID and/or Password")
                } else {
                    displayError("Your request returned a status code other than 2xx!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                displayError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(String(data: newData!, encoding: .utf8)!)
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                //print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(newData!)'")
                return
            }
            guard let dic = parsedResult["session"] as? [String: AnyObject] else {
                print("problem")
                return
            }
            guard let id = dic["id"] as? String else {
                print("problem")
                return
            }

            let cookie = HTTPCookie(properties: [
                .domain: ".udacity.com",
                .path: "/",
                .name: "XSRF-TOKEN",
                .value: id,
                .discard: "FALSE"
                ])!
            let sharedCookieStorage = HTTPCookieStorage.shared
            sharedCookieStorage.setCookie(cookie)
            
            let controller: UITabBarController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(controller, animated:true, completion:nil)
        }
        
        /* 7. Start the request */
        task.resume()
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
