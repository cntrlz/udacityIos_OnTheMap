//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by benchmark on 9/14/16.
//  Copyright © 2016 Viktor Lantos. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		emailField.delegate = self
		passwordField.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	@IBAction func login(sender: AnyObject) {
		func showGenericAlertWithTitle(title: String, message: String) {
			dispatch_async(dispatch_get_main_queue()){
				let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
				let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alert.addAction(ok)
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
		
		// Do not allow blank entries
		if (emailField.text! == "" || passwordField.text! == "") {
			showGenericAlertWithTitle("Login failed", message: "Please enter valid text for both fields")
			return
		}
		
		activityIndicator.startAnimating()
		loginButton.enabled = false
		dismissKeyboard()
		
		if Reachability.isConnectedToNetwork() == true {
			Client.sharedInstance().loginWithUsername(emailField.text!, password: passwordField.text!) { (response, error) in
				dispatch_async(dispatch_get_main_queue()){
					self.activityIndicator.stopAnimating()
					self.loginButton.enabled = true
				}
				
				if error != nil {
					showGenericAlertWithTitle("Login failed", message: error!.localizedDescription)
				} else {
					dispatch_async(dispatch_get_main_queue()) {
						let controller = self.storyboard!.instantiateViewControllerWithIdentifier("mainTab")
						self.presentViewController(controller, animated: true, completion: nil)
					}
				}
			}

		} else {
			showGenericAlertWithTitle("Connection Error", message: "Check your internet connectivity and try again")
			return
		}
		
	}
	
	@IBAction func signup(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string:Client.Constants.UdacitySignup)!)
	}
	
	// MARK: Text Field Delegate
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if (textField == emailField){
			passwordField.becomeFirstResponder()
		} else if (textField == passwordField){
			passwordField.resignFirstResponder()
			login(textField)
		}
		
		return true
	}
	
	// MARK: - Keyboard Management
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name:
			UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:
			UIKeyboardWillHideNotification, object: nil)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		let bottom = CGPointMake(0, view.frame.size.height)
		let lowestPointToShow = CGPointMake(0, loginButton.frame.origin.y + loginButton.frame.size.height)
		let keyboardTop = CGPointMake(0, bottom.y - getKeyboardHeight(notification))
		let wiggleRoom = CGFloat(10.0)
		
		// Always keep the top of the keyboard a certain distance from the lowest point we want to show, with wiggle room
		keyboardTop.y < view.convertPoint(lowestPointToShow, toView: view.window).y ? (view.frame.origin.y = (lowestPointToShow.y - keyboardTop.y + wiggleRoom) * (-1)) : (view.frame.origin.y = (keyboardTop.y - lowestPointToShow.y - wiggleRoom))
	}
	
	func keyboardWillHide(notification: NSNotification) {
		view.frame.origin.y = 0
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	@IBAction func backgroundTapped(sender: AnyObject) {
		dismissKeyboard()
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}
