//
//  StudentArray.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 12/17/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit

final class StudentArray {
    static var sharedInstance = [StudentInformation]()
    let studentArray: [StudentInformation]
    private init(studentArray: [StudentInformation]) {self.studentArray = studentArray}
}
