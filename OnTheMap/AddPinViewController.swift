//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by benchmark on 9/19/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
	
	// IBOutlets
	@IBOutlet weak var findLocationView: UIView!
	@IBOutlet weak var locationField: UITextField!
	@IBOutlet weak var findButton: UIButton!
	
	@IBOutlet weak var confirmView: UIView!
	@IBOutlet weak var shareField: UITextField!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var submitButton: UIButton!
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	// Variables
	var firstResult : CLPlacemark!
	let sharePlaceholder = "Enter a Link to Share Here"
	let locationPlaceholder = "Enter Your Location Here"
	
	// MARK: View Management
    override func viewDidLoad() {
        super.viewDidLoad()

		locationField.delegate = self
		shareField.delegate = self
		mapView.delegate = self
		
		confirmView.hidden = true
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		
	}
	
	func showConfirmView(){
		self.confirmView.hidden = false
		self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		mapView.setRegion(MKCoordinateRegionMakeWithDistance((firstResult.location?.coordinate)!, 4000, 4000), animated: true)
		
		let myPin = MKPointAnnotation()
		myPin.coordinate = (firstResult.location?.coordinate)!
		myPin.title = "Me!"
		myPin.subtitle = "my share link"
		
		mapView.addAnnotation(myPin)
	}
	
	// MARK: User Actions
	@IBAction func findOnMap(sender: AnyObject) {
		if (locationField.text != "" && locationField.text != locationPlaceholder){
			geoCodeLocation(locationField.text!, completion: { (placemark, error) in
				if placemark != nil {
					self.firstResult = placemark!
					dispatch_async(dispatch_get_main_queue()){
						self.showConfirmView()
					}
				}
			})
		} else {
			showGenericAlertWithTitle("No Location", message: "Please enter a valid location to continue")
		}
	}
	
	@IBAction func submit(sender: AnyObject) {
		if (shareField.text! == "" || shareField.text! == sharePlaceholder){
			let alert = UIAlertController(title: "No URL", message: "Are you sure you want to submit your location without a share link?", preferredStyle: .Alert)
			let confirm = UIAlertAction(title: "Submit", style: .Destructive, handler: { action in
				self.addPin()
			})
			let stay = UIAlertAction(title: "Add URL", style: .Default, handler: nil)
			alert.addAction(confirm)
			alert.addAction(stay)
			presentViewController(alert, animated: true, completion: nil)
		} else {
			let url = shareField.text!
			if UIApplication.sharedApplication().canOpenURL(NSURL(string: url)!){
				addPin()
			} else {
				// Did they just leave off the www or the http://, or both? Try the url these ways as well
				if UIApplication.sharedApplication().canOpenURL(NSURL(string: "www."+url)!){
					shareField.text = "wwww."+url
					addPin()
				} else if UIApplication.sharedApplication().canOpenURL(NSURL(string: "http://"+url)!){
					shareField.text = "http://"+url
					addPin()
				} else if UIApplication.sharedApplication().canOpenURL(NSURL(string: "http://www."+url)!){
					shareField.text = "http://wwww."+url
					addPin()
				} else {
					showGenericAlertWithTitle("Invalid URL", message: "Please enter a valid url to continue")
				}
			}
			
		}
	}
	
	@IBAction func cancel(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: Map View Delegate
	// Hide the keyboard when we move the map around
	func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		self.view.endEditing(true)
	}
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("myPin") as? MKPinAnnotationView
		
		// Set up the pin view if we are creating a new one
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
			pinView!.canShowCallout = true
		}
		// Otherwise reuse as-is
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	// MARK: Text Field Delegate
	func textFieldDidBeginEditing(textField: UITextField) {
		if ((textField == locationField && textField.text == locationPlaceholder) || ((textField == shareField && textField.text == sharePlaceholder))){
			textField.text = ""
		}
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		if (textField.text! == ""){
			if (textField == locationField){
				textField.text = locationPlaceholder
			} else {
				textField.text = sharePlaceholder
			}
		}
		
		return true
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		view.endEditing(true)
		return true
	}
	
	// MARK: Alerts
	func showGenericAlertWithTitle(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alert.addAction(ok)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: Geocoding
	func geoCodeLocation(location: String, completion:(placemark:CLPlacemark?, error: NSError?) -> Void){
		let geocoder = CLGeocoder()
		
		geocoder.geocodeAddressString(location) { (placemarks, error) in
			if (error != nil){
				self.showGenericAlertWithTitle("No results", message: "Could not find location.")
			} else {
				if let placemark : CLPlacemark? = placemarks!.first{
					completion(placemark: placemark, error: nil)
				}
			}
		}
	}
	
	// MARK: API Calls
	func addPin(){
		activityIndicator.startAnimating()
		let latitude = Double(firstResult.location!.coordinate.latitude)
		let longitude = Double(firstResult.location!.coordinate.longitude)
		
		Client.sharedInstance().addPinAtLocation(locationField.text!, latitude: latitude, longitude: longitude, url: shareField.text!) { (success, error) in
			dispatch_async(dispatch_get_main_queue()){
				self.activityIndicator.stopAnimating()
			}
			
			if (error != nil){
				dispatch_async(dispatch_get_main_queue()){
					self.showGenericAlertWithTitle("Adding Pin Failed", message: "Could not add your pin to the map! \(error!.localizedDescription)")
				}
			}
			
			if (success){
				dispatch_async(dispatch_get_main_queue()){
					// Lame hack to force mapView to update anew
					Students.sharedInstance().locations = []
					self.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
	}
}
