//
//  LogOut.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 12/10/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import Foundation

class LogOut: NSObject {

    override init() {
        super.init()
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
    let range = Range(5..<data!.count)
    let newData = data?.subdata(in: range) /* subset response data! */
    completionHandlerForLogOut(newData, error! as NSError)
    //print(String(data: newData!, encoding: .utf8)!)
    }
    task.resume()
    return task
    }
    
    /*class func sharedInstance() -> SIClient {
        struct Singleton {
            static var sharedInstance = SIClient()
        }
        return Singleton.sharedInstance
    }*/

}
