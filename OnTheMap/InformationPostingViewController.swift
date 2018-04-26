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
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addNewPin(_ sender: Any) {
        bolSubmit = true
        if verifyUrl(urlString: URLTextField.text) {
            addPin(sender)
        } else {
            generateAlert(alrtMessage: "Invalid URL")
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        print("add pin")
        if LocationTextField.text == "" {
            generateAlert(alrtMessage: "Enter a Location")
        } else {
            manageDisplay(bolMap: false)
            self.activityIndicatorView.startAnimating()
            CLGeocoder().geocodeAddressString(LocationTextField.text!, completionHandler: {(placemarks, error)->Void in
                if error == nil {
                    var placemark: CLPlacemark!
                    placemark = placemarks?[0]
                    self.StuddentMapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake ((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!), MKCoordinateSpanMake(0.002, 0.002)), animated: true)
                    self.activityIndicatorView.stopAnimating()
                    let dblLong = (placemark.location?.coordinate.longitude)!
                    let dblLat = (placemark.location?.coordinate.latitude)!
                    if self.bolSubmit == true {
                        let _ = SIClient.sharedInstance.addPin(mapString: self.LocationTextField.text!, mediaURL: self.URLTextField.text!, latitude: dblLat, longitude: dblLong) { (data, error) in
                            if error == nil {
                                self.segInfoPost(sender)
                            } else {
                                let alert = UIAlertController(title: "Alert", message: "There was a problem logging in!", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    self.generateAlert(alrtMessage: "Invalid Location")
                }
            })
        }
    }

    @IBOutlet weak var URLTextField: UITextField!
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var StuddentMapView: MKMapView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        manageDisplay(bolMap: true)
        self.LocationTextField.delegate = self as UITextFieldDelegate
        self.URLTextField.delegate = self as UITextFieldDelegate
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
        StuddentMapView.isHidden = bolMap
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
