//
//  Pins.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/20/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//



// MARK: - TMDBClient: NSObject
struct StudentInformation {

    let title: String
    let id: Int
    let posterPath: String?
    let releaseYear: String?
    
    init(dictionary: [String:AnyObject]) {
        title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
        
        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String, releaseDateString.isEmpty == false {
            releaseYear = releaseDateString.substring(to: releaseDateString.characters.index(releaseDateString.startIndex, offsetBy: 4))
        } else {
            releaseYear = ""
        }
    }

    static func moviesFromResults(_ results: [[String:AnyObject]]) -> [TMDBMovie] {
        
        var movies = [TMDBMovie]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            movies.append(TMDBMovie(dictionary: result))
        }
        
        return movies
    }
    
    public func getPins() -> [[String:AnyObject]] {
        print("getPins")
        var pins = [[String:AnyObject]]()
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
                print(error)
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
                /*print(parsedResult)*/
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data!*/
            do {
                //self.pins = (parsedResult["results"] as? [[String:AnyObject]])!
                //self.tableView.reloadData()
                pins = (parsedResult["results"] as? [[String:AnyObject]])!
            } catch {
                displayError("Could not create the dictionary")
                return
            }
        }
        
        /* 7. Start the request */
        task.resume()
        return pins
    }
}
