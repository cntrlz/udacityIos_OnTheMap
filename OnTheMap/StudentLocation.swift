//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by benchmark on 9/15/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit

struct StudentLocation {
	
	let objectId: String
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let mapString: String
	let mediaURL: String
	let latitude: Double
	let longitude: Double
	let createdAt: String
	let updatedAt: String
	
	init?(dictionary: [String:AnyObject]) {
		
		//https://discussions.udacity.com/t/app-crashing-at-login-after-parse-update/182059/5?u=michael_135862232227
		
		guard let object = dictionary[Client.StudentLocationKeys.ObjectId] as? String else { return nil }
		objectId = object
		guard let unique = dictionary[Client.StudentLocationKeys.UniqueKey] as? String else { return nil }
		uniqueKey = unique
		guard let first = dictionary[Client.StudentLocationKeys.FirstName] as? String else { return nil }
		firstName = first
		guard let last = dictionary[Client.StudentLocationKeys.LastName] as? String else { return nil }
		lastName = last
		guard let map = dictionary[Client.StudentLocationKeys.MapString] as? String else { return nil }
		mapString = map
		guard let url = dictionary[Client.StudentLocationKeys.MediaURL] as? String else { return nil }
		mediaURL = url
		guard let lat = dictionary[Client.StudentLocationKeys.Latitude] as? Double else { return nil }
		latitude = lat
		guard let long = dictionary[Client.StudentLocationKeys.Longitude] as? Double else { return nil }
		longitude = long
		guard let created = dictionary[Client.StudentLocationKeys.CreatedAt] as? String else { return nil }
		createdAt = created
		guard let updated = dictionary[Client.StudentLocationKeys.UpdatedAt] as? String else { return nil }
		updatedAt = updated
	}
}
