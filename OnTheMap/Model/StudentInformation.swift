//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/20/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//



// MARK: - StudentInformation: NSObject
struct StudentInformation {

    let latitude: Double!
    let longitude: Double!
    let firstName: String
    let lastName: String
    let mediaURL: String
    
    init(dictionary: [String:AnyObject]) {
        if let latitudeString = dictionary[SIClient.JSONResponseKeys.latitude] as? Double {
            latitude = latitudeString
        } else {
            latitude = nil
        }
        if let longitudeString = dictionary[SIClient.JSONResponseKeys.longitude] as? Double {
            longitude = longitudeString
        } else {
            longitude = nil
        }
        if let firstNameString = dictionary[SIClient.JSONResponseKeys.firstName] as? String {
            firstName = firstNameString
        } else {
            firstName = ""
        }
        if let lastNameString = dictionary[SIClient.JSONResponseKeys.lastName] as? String {
            lastName = lastNameString
        } else {
            lastName = ""
        }
        if let mediaURLString = dictionary[SIClient.JSONResponseKeys.mediaURL] as? String {
            mediaURL = mediaURLString
        } else {
            mediaURL = ""
        }
    }

    //static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
    static func studentsFromResults(_ results: [[String:AnyObject]]) {
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        StudentArray.sharedInstance = students
        //return students
    }
}
