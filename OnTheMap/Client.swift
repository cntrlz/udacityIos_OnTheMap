//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by benchmark on 9/14/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Client: NSObject

class Client : NSObject {
	
	// MARK: Properties
	var session = NSURLSession.sharedSession()
	
	// authentication state
	var requestToken: String? = nil
	var sessionID: String? = nil
	var userID: String? = nil
	var userFirstName: String? = nil
	var userLastName: String? = nil
	
	// MARK: Initializers
	
	override init() {
		super.init()
	}
	
	// MARK: Shared Instance
	class func sharedInstance() -> Client {
		struct Singleton {
			static var sharedInstance = Client()
		}
		return Singleton.sharedInstance
	}
	
	// MARK: Generic HTTP Requests
	func get(url: String, parameters: [String:AnyObject]?, completion:(response: AnyObject!, error: NSError?) -> Void){
		// Set up our url and parameters
		let components = NSURLComponents(string: url)!
		components.queryItems = [NSURLQueryItem]()
		
		if parameters != nil {
			for (key, value) in parameters! {
				components.queryItems!.append(NSURLQueryItem(name: key, value: "\(value)"))
			}
		}
		
		// Create our request
		let request = NSMutableURLRequest(URL: components.URL!)
		
		// If we are accessing parse.udacity.com, add our appID and apiKey to our headers. They are required.
		if (url.containsString("parse.udacity.com")){
			request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
			request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		}
		
		// Make the request and check for errors
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			func sendError(error: String) {
				let userInfo = [NSLocalizedDescriptionKey : error]
				completion(response: nil, error: NSError(domain: "POST", code: 1, userInfo: userInfo))
			}
			
			// Check for error, successful 2XX response, and whether we have data
			guard (error == nil) else {
				sendError("There was an error with your request: \(error)")
				return
			}
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				sendError("Unsuccessful status code!")
				return
			}
			guard let data = data else {
				sendError("No data was received")
				return
			}
			
			// If everything is good, parse and send off data. Note that Udacity responses must be trimmed
			if (url.containsString("www.udacity.com")){
				self.parseData(self.trimData(data), completion: completion)
			} else {
				self.parseData(data, completion: completion)
			}
			
		}
		
		// Start Request
		task.resume()
	}
	
	
	func post(url: String, parameters: [String:AnyObject], completion:(response: AnyObject!, error: NSError?) -> Void){
		
		// Create our request
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		// Add our parameters as JSON
		if NSJSONSerialization.isValidJSONObject(parameters){
			let json = try! NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
			request.HTTPBody = json
		}
		
		// If we are POSTing to parse.udacity.com, add our appID and apiKey to our headers. They are required.
		if (url.containsString(Constants.ParseApiHost)){
			request.addValue(Constants.AppID, forHTTPHeaderField: ParseHeaders.AppIDHeader)
			request.addValue(Constants.ApiKey, forHTTPHeaderField: ParseHeaders.ApiKeyHeader)
		}
		
		// Make the request and check for errors
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			func sendError(error: String) {
				let userInfo = [NSLocalizedDescriptionKey : error]
				completion(response: nil, error: NSError(domain: "POST", code: 1, userInfo: userInfo))
			}
			
			// Check for error, successful 2XX response, and whether we have data
			guard (error == nil) else {
				sendError("There was an error with your request: \(error)")
				return
			}
			let statusCode = (response as? NSHTTPURLResponse)?.statusCode
			guard (statusCode >= 200 && statusCode <= 299) else {
				// Look specifically for an unauth status code. This will happen if our login or session data is invalid.
				// Eventually, get some constants going to define error types and alert messages shown to user
				if statusCode == 403 {
					sendError("Unauthorized - invalid credentials")
					return
				}
				sendError("Unsuccessful status code!")
				return
			}
			guard let data = data else {
				sendError("No data was received")
				return
			}
			
			// If everything is good, parse and send off data. Note that Udacity responses must be trimmed
			if (url.containsString(Constants.UdacityApiHost)){
				self.parseData(self.trimData(data), completion: completion)
			} else {
				self.parseData(data, completion: completion)
			}
			
		}
		
		// Start Request
		task.resume()
	}
	
	// MARK: Helpers
	func parseData(data: NSData, completion: (response: AnyObject!, error: NSError?) -> Void) {
		var parsedResult: AnyObject!
		
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Failed to parse the data as JSON: '\(data)'"]
			completion(response: nil, error: NSError(domain: "parseData", code: 1, userInfo: userInfo))
		}
		
		completion(response: parsedResult, error: nil)
	}
	
	// Trim the first 5 characters (security) off a data response; Needed for Udacity responses only
	func trimData(data: NSData) -> NSData {
		return data.subdataWithRange(NSMakeRange(5, data.length - 5))
	}
	

	
	// MARK: Under Construction
	// Generic PUT Request not implemented yet!
	func put(url: String, parameters: [String:AnyObject], completion:(result: AnyObject!, error: NSError?) -> Void){
		
	}
	
	// Generic DELETE Request not implemented yet!
	func delete(url: String, parameters: [String:AnyObject], completion:(result: AnyObject!, error: NSError?) -> Void){
		
	}
}