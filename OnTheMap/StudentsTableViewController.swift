//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by benchmark on 9/14/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController {
	// MARK: View Management
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}
	
	// MARK: Alerts
	func showGenericAlertWithTitle(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alert.addAction(ok)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: User Actions
	
	@IBAction func refresh(sender: AnyObject) {
		updateLocations()
	}
	
	@IBAction func logout(sender: AnyObject) {
		Client.sharedInstance().logout { (success, error) in
			if (success){
				self.dismissViewControllerAnimated(true, completion: nil)
			} else {
				dispatch_async(dispatch_get_main_queue()){
					self.showGenericAlertWithTitle("Logout Failed", message: "Could not log you out of the app! \(error!.localizedDescription)")
				}
			}
		}
	}
	
	// MARK: API Calls
	func updateLocations() {
		Client.sharedInstance().updateLocations(100, skip: 0, order: "-updatedAt") { (response, error) in
			// If we have successfully updated our model's data...
			if (error != nil){
				if error!.code != 2 {
					dispatch_async(dispatch_get_main_queue()){
						self.showGenericAlertWithTitle("Update Failed", message: "Could not get list of nearby students: \(error?.localizedDescription)")
					}
				} else {
					dispatch_async(dispatch_get_main_queue()){
						self.showGenericAlertWithTitle("Update Partially Failed", message: "Could not get full list of students. Some might be missing.")
						self.tableView.reloadData()
					}
				}
			} else {
				dispatch_async(dispatch_get_main_queue()){
					self.tableView.reloadData()
				}
			}
		}
	}

    // MARK: TableView data source
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let location = Students.sharedInstance().locations[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier("pinCell") as UITableViewCell!
		cell.textLabel!.text = location.firstName + " " + location.lastName
		
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Students.sharedInstance().locations.count
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let location = Students.sharedInstance().locations[indexPath.row]
		let urlString = location.mediaURL
		var url = NSURL()
		
		// Does it start properly with http or https? If so, make the url as-is.
		// Does it just start with www.? If so, add http
		// If none of these are true, use the URL as-is and rely on canOpenURL
		if urlString.hasPrefix("http://") || urlString.hasPrefix("https://"){
			url = NSURL(string: urlString)!
		} else if urlString.hasPrefix("www.") {
			url = NSURL(string:"http://"+urlString)!
		} else {
			url = NSURL(string: urlString)!
		}
		
		if UIApplication.sharedApplication().canOpenURL(url){
			UIApplication.sharedApplication().openURL(url)
		} else {
			showGenericAlertWithTitle("Cannot Open URL", message: "The URL associated with this student is missing or malformed")
		}
	}
}
