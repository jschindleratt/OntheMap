//
//  TextDelegate.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/8/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit

class TextDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "EMAIL" || textField.text == "PASSWORD"  {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
