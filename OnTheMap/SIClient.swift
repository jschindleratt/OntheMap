//
//  SIClient.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 11/5/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import Foundation

class SIClient {
    static var userUniqueID: String = "XYZ"
    static var userFirsrtName: String = "JD"
    static var userLastName: String = "Mmmm"
    
    func addPin(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForAddPin: @escaping (_ strMessage: String, _ error: NSError?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(SIClient.userUniqueID)\", \"firstName\": \"\(SIClient.userFirsrtName)\", \"lastName\": \"\(SIClient.userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                print(error as Any)
                return
            } else {
                print(String(data: data!, encoding: .utf8)!)
            }
            completionHandlerForAddPin("success", nil)
        }
        task.resume()
        return task
    }
    
    func getPins(_ completionHandlerForStudents: @escaping (_ studentData: [StudentInformation]?, _ error: NSError?) -> Void) -> URLSessionTask {
        print("getPins")
        /* 1. Set the parameters
         let methodParameters = [
         TMDBClient.ParameterKeys.ApiKey: TMDBClient.Constants.ApiKey
         ]*/
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
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
            //let studentInformation: [StudentInformation] = StudentInformation.studentsFromResults((parsedResult["results"] as? [[String:AnyObject]])!)
            StudentInformation.studentsFromResults((parsedResult["results"] as? [[String:AnyObject]])!)
            let studentInformation: [StudentInformation] = StudentArray.sharedInstance
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

    func logIn(strID: String, strPassword: String, completionHandlerForLogin: @escaping (_ strMessage: String, _ error: NSError?) -> Void) -> URLSessionTask {
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
                    //self.LabelMessage.text = error
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                if error!.localizedDescription == "The Internet connection appears to be offline." {
                    displayError("The Internet connection appears to be offline.")
                } else {
                    displayError("There was an error with your request: \(error!)")
                }
                return
            }
            
            /* GUARD: Did we get a successful 2XX response?*/
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                displayError("Your request did not return a status code!")
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                if statusCode == 403 {
                    print("Invalid ID and/or Password")
                    displayError("Invalid ID and/or Password")
                } else {
                    print("Your request returned a status code other than 2xx!")
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
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
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
            print(id)
            
            let cookie = HTTPCookie(properties: [
                .domain: ".udacity.com",
                .path: "/",
                .name: "XSRF-TOKEN",
                .value: id,
                .discard: "FALSE"
                ])!
            let sharedCookieStorage = HTTPCookieStorage.shared
            sharedCookieStorage.setCookie(cookie)
            
            self.getName(strID: strID)
            completionHandlerForLogin("success", nil)
        }
        
        /* 7. Start the request */
        task.resume()
        return task
    }
    
    func getName(strID: String) {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(strID)")!)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(newData!)'")
                return
            }
            guard let dic = parsedResult["user"] as? [String: AnyObject] else {
                print("problem")
                return
            }
            
            guard let firstName = dic["first_name"] as? String else {
                print("problem")
                return
            }
            guard let lastName = dic["last_name"] as? String else {
                print("problem")
                return
            }
            SIClient.userFirsrtName = firstName
            SIClient.userLastName = lastName
        }
        task.resume()
    }
    
    static let sharedInstance = SIClient()
    private init(){}
    
    /* class func sharedInstance() -> SIClient {
        struct Singleton {
            static var sharedInstance = SIClient()
        }
        return Singleton.sharedInstance
    }*/
 }
