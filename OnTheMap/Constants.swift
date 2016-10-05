//
//  Constants.swift
//  OnTheMap
//
//  Created by benchmark on 9/14/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension Client {
	
	// MARK: Constants
	struct Constants {
		
		// URLS
		static let UdacitySession = "https://www.udacity.com/api/session"
		static let UdacityUsers = "https://www.udacity.com/api/users"
		static let ParseStudentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
		static let UdacitySignup = "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
		
		// MARK: Keys and IDs
		static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
		static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		
		// MARK: URLs
		static let ApiScheme = "https"
		static let ParseApiHost = "parse.udacity.com"
		static let newParseApiHost = "parse.udacity.com/classes"
		static let UdacityApiHost = "www.udacity.com/api"
		
		//static let ApiPath = "/3"
		//static let AuthorizationURL : String = "https://www.udacity.com/api/session"
	}
	
	// MARK: Methods
	struct ParseMethods {
		static let StudentLocation = "/StudentLocation"
		//static let StudentLocation = "/parse/classes/StudentLocation"
	}
	
	struct UdacityMethods {
		static let Users = "/users"
		static let Session = "/session"
	}
	
	// MARK: Custom Headers
	struct ParseHeaders {
		static let AppIDHeader = "X-Parse-Application-Id"
		static let ApiKeyHeader = "X-Parse-REST-API-Key"
	}
	
	// MARK: Student Location Object Keys
	struct StudentLocationKeys {
		static let ObjectId = "objectId"
		static let UniqueKey = "uniqueKey"
		static let FirstName = "firstName"
		static let LastName = "lastName"
		static let MapString = "mapString"
		static let MediaURL = "mediaURL"
		static var Latitude = "latitude"
		static let Longitude = "longitude"
		static let CreatedAt = "createdAt"
		static let UpdatedAt = "updatedAt"
		static let ACL = "ACL"
	}
}