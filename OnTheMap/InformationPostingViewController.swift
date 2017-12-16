//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/29/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    var bolSubmit: Bool = false
    
    @IBAction func segInfoPost(_ sender: Any) {
        let controller: UITabBarController
        controller = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as!UITabBarController
        present(controller, animated: true, completion: nil)
    }

    @IBAction func addNewPin(_ sender: Any) {
        bolSubmit = true
        if verifyUrl(urlString: txbURL.text) {
            addPin(sender)
        } else {
            generateAlert(alrtMessage: "Invalid URL")
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        if txbLocation.text == "" {
            generateAlert(alrtMessage: "Enter a Location")
        } else {
            manageDisplay(bolMap: false)
            self.activityIndicatorView.startAnimating()
            CLGeocoder().geocodeAddressString(txbLocation.text!, completionHandler: {(placemarks, error)->Void in
                if error == nil {
                    var placemark: CLPlacemark!
                    placemark = placemarks?[0]
                    self.mpMap.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake ((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!), MKCoordinateSpanMake(0.002, 0.002)), animated: true)
                    self.activityIndicatorView.stopAnimating()
                    let dblLong = (placemark.location?.coordinate.longitude)!
                    let dblLat = (placemark.location?.coordinate.latitude)!
                    if self.bolSubmit == true {
                        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
                        request.httpMethod = "POST"
                        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
                        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpBody = "{\"uniqueKey\": \"js2387\", \"firstName\": \"JD\", \"lastName\": \"Mmmm\",\"mapString\": \"\(self.txbLocation.text!)\", \"mediaURL\": \"\(self.txbURL.text!)\",\"latitude\": \(dblLat), \"longitude\": \(dblLong)}".data(using: .utf8)
                        let session = URLSession.shared
                        let task = session.dataTask(with: request) { data, response, error in
                            if error != nil { // Handle error…
                                print(error as Any)
                                return
                            }
                            print(String(data: data!, encoding: .utf8)!)
                            self.segInfoPost(sender)
                        }
                        task.resume()
                    }
                } else {
                    self.generateAlert(alrtMessage: "Invalid Location")
                }
            })
        }
    }

    @IBOutlet weak var txbLocation: UITextField!
    
    @IBOutlet weak var txbURL: UITextField!
    
    @IBOutlet weak var mpMap: MKMapView!
    
    @IBOutlet weak var btnFind: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var btnNav: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        manageDisplay(bolMap: true)
        self.txbLocation.delegate = self as UITextFieldDelegate
        self.txbURL.delegate = self as UITextFieldDelegate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.becomeFirstResponder()
        if textField.text == "Location" || textField.text == "URL"  {
            textField.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func manageDisplay(bolMap: Bool) {
        mpMap.isHidden = bolMap
        //txbLocation.isHidden = !bolMap
        //txbURL.isHidden = !bolMap
        //btnFind.isHidden = !bolMap
    }
    
    func generateAlert(alrtMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alrtMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
