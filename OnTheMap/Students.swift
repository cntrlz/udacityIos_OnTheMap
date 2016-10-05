//
//  Students.swift
//  OnTheMap
//
//  Created by benchmark on 9/16/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit

class Students: NSObject {
	var locations = [StudentLocation]()
	
	class func sharedInstance() -> Students {
		struct Singleton {
			static var sharedInstance = Students()
		}
		return Singleton.sharedInstance
	}
}