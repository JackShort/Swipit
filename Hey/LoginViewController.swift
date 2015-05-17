//
//  LoginViewController.swift
//  Hey
//
//  Created by Jack Short on 4/10/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginUser(sender: AnyObject) {
        var username = usernameField.text.lowercaseString
        var password = passwordField.text
        
        if !username.isEmpty && !password.isEmpty {
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                if error == nil {
                    //yass
                    var sb = UIStoryboard(name: "Main", bundle: nil)
                    var vc = sb.instantiateViewControllerWithIdentifier("tabControl") as! UITabBarController
                    self.presentViewController(vc, animated: false, completion: nil)
                } else {
                    println("login bad")
                    println(error)
                }
            })
        }
    }
}