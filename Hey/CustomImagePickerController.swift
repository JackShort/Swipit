//
//  CustomImagePickerController.swift
//  Hey
//
//  Created by Jack Short on 5/17/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import UIKit

class CustomImagePickerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker: UIImagePickerController = UIImagePickerController()
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.cornerRadius = button.frame.height / 2
    }
}