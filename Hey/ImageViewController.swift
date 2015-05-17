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

class ImageViewController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate {
    var photos: [UIImage] = [UIImage]()
    var photoCount: Int = 0
    var keys: [String] = [String]()
    var sender: String!
    var tap: UITapGestureRecognizer!
    var fb: Firebase!
    var previousPage: Int = 0
    var scrollDirection: CGPoint = CGPointMake(0, 0)
    
    var delegate: PhotoSender!
    var scrollView: UIScrollView!
    
//    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fb = Firebase(url: "https://hey-chat.firebaseio.com/" + PFUser.currentUser()!.username!)
        
        photoCount = photos.count
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.bounces = false
        view.addSubview(scrollView)
        var rect = scrollView.bounds
        var cView: UIImageView
        for i in 0...(photos.count - 1) {
            cView = UIImageView()
            cView.frame = rect
            cView.image = scaleToSize(cView.bounds.size, degrees: 0, image: photos[i])
            scrollView.addSubview(cView)
            rect.origin.x += rect.size.width
        }
        
        rect.origin.x += rect.size.width
        
        scrollView.contentSize = CGSizeMake(rect.origin.x, scrollView.bounds.size.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
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
        delegate.photoSentBack(self.sender, keys: keys, photos: photos)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth = scrollView.frame.size.width
        var fractionalPage = scrollView.contentOffset.x / pageWidth;
        var page: Int = lround(Double(fractionalPage))
        var pageOn: Int = Int(fractionalPage)
        var offset = scrollView.contentOffset
        
        if scrollView.contentOffset.x < scrollDirection.x {
            if scrollDirection.x % scrollView.frame.width == 0 {
                scrollView.contentOffset = scrollDirection
            } else {
                var frame = scrollView.frame
                frame.origin.x = frame.size.width * CGFloat(pageOn + 1)
                frame.origin.y = 0
                scrollView.scrollRectToVisible(frame, animated: true)
            }
        }
        
        if pageOn == (photoCount - 1) {
            scrollView.backgroundColor = UIColor(white: (scrollView.contentOffset.x % scrollView.frame.size.width) / scrollView.frame.size.width, alpha: 1)
        }
        
        if previousPage != pageOn && photos.count != 0 {
            photos.removeAtIndex(0)
            fb.childByAppendingPath(keys[0]).removeValue()
            keys.removeAtIndex(0)
        }
        
        if pageOn == (photoCount) {
            delegate.photoSentBack(self.sender, keys: keys, photos: photos)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        previousPage = pageOn
        
        scrollDirection = scrollView.contentOffset
    }
    
    func scaleToSize(size: CGSize, degrees: CGFloat, image: UIImage) -> UIImage {
        
//        var rotatedViewBox = UIView(frame: CGRectMake(0, 0, image.size.width, image.size.height))
//        var t = CGAffineTransformMakeRotation(CGFloat(Double(degrees) * M_PI / 180))
//        rotatedViewBox.transform = t;
//        var rotatedSize = rotatedViewBox.frame.size;
//        
//        //Create the bitmap context
//        UIGraphicsBeginImageContext(rotatedSize);
//        var bitmap = UIGraphicsGetCurrentContext();
//        
//        //Move the origin to the middle of the image so we will rotate and scale around the center.
//        CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
//        
//        //Rotate the image context
//        CGContextRotateCTM(bitmap, CGFloat(Double(degrees) * M_PI / 180))
//        
//        //Now, draw the rotated/scaled image into the context
//        CGContextScaleCTM(bitmap, 1.0, -1.0);
//        CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), image.CGImage);
//        
//        var oldImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width * 1, size.height * 1))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage;
        
    }
}