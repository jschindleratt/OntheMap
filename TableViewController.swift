//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/10/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBAction func doRefresh(_ sender: Any) {
        getPins()
    }

    @IBAction func logOut(_ sender: Any) {
        let _ = SIClient.sharedInstance().logOut() { (data, error) in
            if error == nil {
                performUIUpdatesOnMain {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "There was a problem logging out!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func segInfoPost(_ sender: Any) {
        let controller: InformationPostingViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as!InformationPostingViewController
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var students = [StudentInformation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getPins()
    }

    private func getPins() {
        print("getPins")
        let _ = SIClient.sharedInstance().getPins() { (studentData, error) in
            if error == nil {
                self.students = studentData!
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "There was a problem retrieving student info!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        let student = students[(indexPath as NSIndexPath).row]
        cell.imageView!.image = UIImage(named: "icon_pin")
        cell.textLabel!.text = student.firstName
        //cell.textLabel!.text = "test)"
        //cell.detailTextLabel!.text = "testing detail"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]
        let toOpen = student.mediaURL
        UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
        //UIApplication.shared.open(NSURL(student.mediaURL, options: [:], completionHandler: nil)
        // Grab the DetailVC from Storyboard
        //let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeMeDetailViewController") as! MemeMeDetailViewController
        
        //Populate view controller with data from the selected item
        //detailController.meme = memes[(indexPath as NSIndexPath).row]
        
        // Present the view controller using navigation
        //navigationController!.pushViewController(detailController, animated: true)
    }

}
