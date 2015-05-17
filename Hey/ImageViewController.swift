//
//  imageViewController.swift
//  Hey
//
//  Created by Jack Short on 5/6/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import UIKit
import Parse

protocol PhotoSender {
    func photoSentBack(sender: String, keys: [String], photos: [UIImage])
}

class ImageViewController: UIViewController {
    var photos: [UIImage] = [UIImage]()
    var keys: [String] = [String]()
    var sender: String!
    var tap: UITapGestureRecognizer!
    var fb: Firebase!
    
    var delegate: PhotoSender!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fb = Firebase(url: "https://hey-chat.firebaseio.com/" + PFUser.currentUser()!.username!)
        
        imageView.image = photos[0]
        tap = UITapGestureRecognizer(target: self, action: "touch:")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBarHidden = true
        tabBarController?.tabBar.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func touch(sender: UITapGestureRecognizer) {
        photos.removeAtIndex(0)
        fb.childByAppendingPath(keys[0]).removeValue()
        keys.removeAtIndex(0)
        if photos.isEmpty {
            delegate.photoSentBack(self.sender, keys: keys, photos: photos)
            self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            imageView.image = photos[0]
        }
    }
}