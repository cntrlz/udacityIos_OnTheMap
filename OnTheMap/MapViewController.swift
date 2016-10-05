//
//  MapViewController.swift
//  OnTheMap
//
//  Created by benchmark on 9/14/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	
	var pins: [MKAnnotation] = []
	let locationManager = CLLocationManager()
	
	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: View Management
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
		
		mapView.delegate = self
		mapView.showsUserLocation = true
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if Students.sharedInstance().locations.isEmpty == true {
			updateLocations()
		} else {
			// Refresh from data on each appearance
			parseAnnotationsFromDataAndRefresh()
		}
	}
	
	// MARK: Alerts
	func showGenericAlertWithTitle(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alert.addAction(ok)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: User Actions
	
	@IBAction func refresh(sender: AnyObject?) {
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
	func updateLocations(){
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
						self.parseAnnotationsFromDataAndRefresh()
					}
				}
			} else {
				dispatch_async(dispatch_get_main_queue()){
					self.parseAnnotationsFromDataAndRefresh()
				}
			}
		}
	}
	
	// MARK: MapView
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("studentPin") as? MKPinAnnotationView
		
		// Set up the pin view if we are creating a new one
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "studentPin")
			pinView!.canShowCallout = true
			pinView!.rightCalloutAccessoryView = UIButton(type: .InfoLight)
		}
		// Otherwise reuse as-is
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			if let subtitle = view.annotation?.subtitle! {
				if UIApplication.sharedApplication().canOpenURL(NSURL(string: subtitle)!){
					UIApplication.sharedApplication().openURL(NSURL(string: subtitle)!)
				} else {
					showGenericAlertWithTitle("Cannot Open URL", message: "The URL associated with this student is missing or malformed")
				}
				//UIApplication.sharedApplication().openURL(NSURL(string: subtitle)!)
			}
		}
	}

	func parseAnnotationsFromDataAndRefresh(){
		self.pins = []
		
		for student in Students.sharedInstance().locations {
			
			let lat = student.latitude
			let long = student.longitude
			let mediaURL = student.mediaURL
			let annotation = MKPointAnnotation()
			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
			
			annotation.coordinate = coordinate
			annotation.title = student.firstName + " " + student.lastName
			annotation.subtitle = mediaURL
			self.pins.append(annotation)
		}
		
		mapView.removeAnnotations(mapView.annotations)
		mapView.addAnnotations(pins)
	}
}