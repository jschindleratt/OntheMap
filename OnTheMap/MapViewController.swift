//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/20/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var students: [StudentInformation]?
    
    @IBAction func logOut(_ sender: Any) {
        let _ = SIClient.sharedInstance().logOut() { (data, error) in
            if error == nil {
                performUIUpdatesOnMain {
                    let controller: LoginViewController
                    controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as!LoginViewController
                    self.present(controller, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "There was a problem logging out!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func doRefresh(_ sender: Any) {
        getPins()
    }
    
    @IBAction func segInfoPost(_ sender: Any) {
        let controller: InformationPostingViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as!InformationPostingViewController
        present(controller, animated: true, completion: nil)
    }

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPins()
    }

    func pinTheMap() {
        if let students = students {
            var annotations = [MKPointAnnotation]()
            for student in students {
            
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
            
                let lat = CLLocationDegrees(student.latitude)
                let long = CLLocationDegrees(student.longitude)
            
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
                let first = student.firstName
                let last = student.lastName
                let mediaURL = student.mediaURL
                if first == "JD" {
                    print("lat: \(lat) long: \(long))")
                }
            
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
            
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        
            // When the array is complete, we add the annotations to the map.
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func getPins() {
        let _ = SIClient.sharedInstance().getPins() { (studentData, error) in
            if error == nil {
                self.students = studentData
                self.pinTheMap()
            } else {
                let alert = UIAlertController(title: "Alert", message: "There was a problem retrieving student info!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
