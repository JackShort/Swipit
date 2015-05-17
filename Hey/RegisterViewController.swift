//
//  RegisterViewController.swift
//  Hey
//
//  Created by Jack Short on 4/10/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerUser(sender: AnyObject) {
        if !usernameField.text.isEmpty && !passwordField.text.isEmpty && !emailField.text.isEmpty {
            
            let user = PFUser()
            user.username = usernameField.text.lowercaseString
            user.password = passwordField.text
            user.email = emailField.text
            
            user.signUpInBackgroundWithBlock({ (succeded, error) -> Void in
                if error == nil {
                    //nice
                    var sb = UIStoryboard(name: "Main", bundle: nil)
                    var vc = sb.instantiateViewControllerWithIdentifier("tabControl") as! UITabBarController
                    self.presentViewController(vc, animated: false, completion: nil)
                } else {
                    //bad 
                    println("should warn user about soemtihgin")
                    println(error)
                }
            })
        }
    }
}