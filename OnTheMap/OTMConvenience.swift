//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by benchmark on 9/16/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit
import MapKit

extension Client {
	// MARK: Authentication
	func loginWithUsername(username: String, password: String, completion: (response: AnyObject!, error: NSError?) -> Void){
		post(Constants.UdacitySession, parameters: ["udacity":["username": username, "password": password]]) { (loginResponse, error) in
			if error != nil {
				completion(response: nil, error: error)
			} else {
				// Get our userID and sessionID; store them
				if let accountDetails = loginResponse as? [String: AnyObject] {
					if ((accountDetails["error"]) != nil){
						let userInfo = [NSLocalizedDescriptionKey : "Failed to fetch account details"]
						completion(response: nil, error: NSError(domain: "accountDetailFailure", code: 1, userInfo: userInfo))
					} else {
						let account = accountDetails["account"] as! [String: AnyObject]
						let session = accountDetails["session"] as! [String: AnyObject]

						Client.sharedInstance().userID = account["key"] as? String
						Client.sharedInstance().sessionID = session["id"] as? String
					}
				}
				
				guard Client.sharedInstance().userID != nil else {
					let userInfo = [NSLocalizedDescriptionKey : "Failed to fetch userID"]
					completion(response: nil, error: NSError(domain: "userIDFailure", code: 1, userInfo: userInfo))
					return
				}
				
				
				// On each login, also run our ID to grab our profile info and store it
				self.getPublicDataForUserID(Client.sharedInstance().userID!, completion: { (pubDataReponse, error) in
					if error != nil {
						completion(response: nil, error: error)
					} else {
						self.updateUserData(pubDataReponse, completion: { (success, error) in
							if error != nil {
								let userInfo = [NSLocalizedDescriptionKey : "Failed to fetch profile information"]
								completion(response: nil, error: NSError(domain: "profileFetchFailure", code: 1, userInfo: userInfo))
							} else {
								completion(response: pubDataReponse, error: nil)
							}
						})
					}
				})
			}
		}
	}
	
	func logout(completion:(success: Bool, error: NSError?) -> Void){
		let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacitySession)!)
		request.HTTPMethod = "DELETE"
		var xsrfCookie: NSHTTPCookie? = nil
		let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil {
				let userInfo = [NSLocalizedDescriptionKey : "Logout failed"]
				completion(success: false, error: NSError(domain: "logoutFailure", code: 1, userInfo: userInfo))
			} else {
				completion(success:true, error:nil)
			}
		}
		task.resume()
	}
	
	// MARK: Locations
	// Also updates our data model. How convenient!
	func updateLocations(limit: NSInteger, skip: NSInteger, order: String, completion:(response: AnyObject!, error: NSError?) -> Void){
		get(Constants.ParseStudentLocation, parameters: ["limit": limit, "skip": skip, "order":order]) { (response, error) in
			if error != nil {
				completion(response: nil, error: error)
			} else {
				self.parseLocationsFromResponseAndUpdateData(response, completion: { (success, error) in
					if error != nil {
						completion(response: nil, error: error)
					} else {
						completion(response: response, error: nil)
					}
				})
			}
		}
	}
	
	// MARK: Profile Information
	func getPublicDataForUserID(userID: String, completion: (response: AnyObject!, error: NSError?) -> Void){
		get(Constants.UdacityUsers+"/\(userID)", parameters: nil) { (response, error) in
			if error != nil {
				completion(response: nil, error: error)
			} else {
				completion(response: response, error: nil)
			}
		}
	}
	
	// MARK: Parsing
	func parseLocationsFromResponseAndUpdateData(response: AnyObject!, completion:(success: Bool, error: NSError?) -> Void){
		if let json = (response["results"] as? [[String:AnyObject]]){
			var locationsArray:[StudentLocation] = []
			
			var wasError = false
			
			// Sometimes parsing can fail. Alert the user if something doesn't go right
			for student in json {
				if let location = StudentLocation(dictionary: student){
					locationsArray.append(location)
				} else {
					wasError = true
					print("Couldn't parse student location: \(student)")
				}
			}
			
			Students.sharedInstance().locations = locationsArray
			if wasError {
				let userInfo = [NSLocalizedDescriptionKey : "One or more locations were not parsed appropriately"]
				completion(success: false, error: NSError(domain: "parseLocationsFromResponse", code: 2, userInfo: userInfo))
			} else {
				completion(success: true, error: nil)
			}
		} else {
			let userInfo = [NSLocalizedDescriptionKey : "Failed to parse results from response"]
			completion(success: false, error: NSError(domain: "parseLocationsFromResponse", code: 1, userInfo: userInfo))
		}
	}
	
	func updateUserData(response: AnyObject!, completion:(success: Bool, error: NSError?) -> Void){
		if let userData = response as! NSDictionary! {
			let user = userData["user"]!
			
			if let lastName = user["last_name"] as? String {
				self.userLastName = lastName
			} else {
				let userInfo = [NSLocalizedDescriptionKey : "Failed to parse LastName"]
				completion(success: false, error: NSError(domain: "lastNameParseFailure", code: 1, userInfo: userInfo))
			}
			
			if let firstName = user["first_name"] as? String {
				self.userFirstName = firstName
			} else {
				let userInfo = [NSLocalizedDescriptionKey : "Failed to parse LastName"]
				completion(success: false, error: NSError(domain: "lastNameParseFailure", code: 1, userInfo: userInfo))
			}
			
			completion(success: true, error: nil)
		} else {
			let userInfo = [NSLocalizedDescriptionKey : "Could not parse user key"]
			completion(success: false, error: NSError(domain: "userParseFailure", code: 1, userInfo: userInfo))
		}
	}
	
	// MARK: Pins
	// POST with custom HTTP headers and json body
	func addPinAtLocation(location: String!, latitude: Double, longitude: Double, url: String!, completion: (success: Bool, error: NSError?) -> Void){
		let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
		request.HTTPMethod = "POST"
		request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		// Make sure we have a valid userID, userFirstName, and userLastName
		request.HTTPBody = "{\"uniqueKey\": \"\(userID!)\", \"firstName\": \"\(userFirstName!)\", \"lastName\": \"\(userLastName!)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(url)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil {
				return
			}
		}
		task.resume()
		completion(success: true, error: nil)
	}
}
