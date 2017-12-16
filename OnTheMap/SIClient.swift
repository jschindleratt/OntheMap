//
//  SIClient.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 11/5/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import Foundation

class SIClient: NSObject {
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func getPins(_ completionHandlerForStudents: @escaping (_ studentData: [StudentInformation]?, _ error: NSError?) -> Void) -> URLSessionTask {
        print("getPins")
        /* 1. Set the parameters
         let methodParameters = [
         TMDBClient.ParameterKeys.ApiKey: TMDBClient.Constants.ApiKey
         ]*/
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print("err: \(error)")
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                    //self.debugTextLabel.text = "Login Failed (Request Token)."
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data*/
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                //print(parsedResult)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }

            /* 6. Use the data!*/
            let studentInformation: [StudentInformation] = StudentInformation.studentsFromResults((parsedResult["results"] as? [[String:AnyObject]])!)
            completionHandlerForStudents(studentInformation, nil)
        }
        task.resume()
        return task
    }

    func logOut(_ completionHandlerForLogOut: @escaping (_ logOutData: Data?, _ error: NSError?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            completionHandlerForLogOut(data, nil)
        }
        task.resume()
        return task
    }
    
    class func sharedInstance() -> SIClient {
        struct Singleton {
            static var sharedInstance = SIClient()
        }
        return Singleton.sharedInstance
    }
        
 }

