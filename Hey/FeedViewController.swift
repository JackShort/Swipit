//
//  File.swift
//  Hey
//
//  Created by Jack Short on 4/11/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import Parse


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoSender {
    var fb = Firebase(url: "https://hey-chat.firebaseio.com/")
    var personalFb: Firebase!
    var chats: [String: [UIImage]] = [String: [UIImage]]()
    var chatKeys: [String: [String]] = [String: [String]]()
    var usernames: [String] = [String]()
    var picturesToSend: [UIImage] = [UIImage]()
    var keysToSend: [String] = [String]()
    var sender: String = ""
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    let cellId = "cellId"
    
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        when you add a class do this --yeah ik --um no you didn't you twat --i hate you --i will kill you --same
        self.table.registerClass(FeedCell.classForCoder(), forCellReuseIdentifier: cellId)
        
        personalFb = fb.childByAppendingPath(PFUser.currentUser()?.username)
        setupFirebase()
    }
    
    func setupFirebase() {
        self.personalFb.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
            let senderUsername: String = snapshot.value["sender"] as! String
            let snap = snapshot.value["pic"] as? String
            
            if snap != nil {
                var pic: UIImage = self.convertStringToImage(snap!)
                
                if contains(self.usernames, senderUsername) {
                    self.usernames.removeObject(senderUsername)
                }
                
                self.usernames.insert(senderUsername, atIndex: 0)
                if self.chats[senderUsername] == nil {
                    self.chats[senderUsername] = []
                    self.chatKeys[senderUsername] = []
                }
                self.chats[senderUsername]?.append(pic)
                self.chatKeys[senderUsername]?.append(snapshot.key)
                self.table.reloadData()
            }
            
        })
    }
    
    //functions for shit
    func convertStringToImage(snap: String) -> UIImage {
        let decodedData = NSData(base64EncodedString: snap, options: nil)
        var photo: UIImage = UIImage(data: decodedData!)!
 
        return photo
    }
    
    //table functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : FeedCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? FeedCell
        
//        getPictureForCell(chats[indexPath.row], cell: cell!)
        
//        var textLabel = cell?.viewWithTag(2) as UILabel
//        textLabel.text = chats[indexPath.row]
        
//        cell!.mainLabel.text = chats[indexPath.row]
//        cell!.mainImageView.image = UIImage.imageWithImage(UIImage(named: "defaultProfile.jpg"), newSize: CGSizeMake(cell!.height!, cell!.height!))
        
        cell?.textLabel?.text = usernames[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if chats[usernames[indexPath.row]] != nil {
            picturesToSend = chats[usernames[indexPath.row]]!
            keysToSend = chatKeys[usernames[indexPath.row]]!
            sender = usernames[indexPath.row]
            performSegueWithIdentifier("showImage", sender: self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.showsCameraControls = false
        imagePicker.delegate = self
        
        var translate = CGAffineTransformMakeTranslation(0.0, 71.0)
        imagePicker.cameraViewTransform = translate;
        
        var scale = CGAffineTransformScale(translate, 1.333333, 1.333333)
        imagePicker.cameraViewTransform = scale;
        
        var overlay = createOverlay()
        imagePicker.cameraOverlayView = overlay
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
        //Just send a random photo to the noob over there smh people these days
//        var size = CGSizeMake(view.bounds.width, view.bounds.height)
//        UIGraphicsBeginImageContextWithOptions(size, true, 0)
//        UIColor.blueColor().setFill()
//        UIRectFill(CGRectMake(0, 0, size.width, size.height))
//        var image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        let imageData = UIImagePNGRepresentation(image)
//        let imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
//        var message = [
//            "sender": PFUser.currentUser()!.username!,
//            "pic": imageString
//        ]
//    
//        fb.childByAppendingPath("jack").childByAutoId().setValue(message)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var vc: SendPhotoViewController = SendPhotoViewController()
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        vc.photo = image
        picker.pushViewController(vc, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            var vc = segue.destinationViewController as! ImageViewController
            vc.photos = picturesToSend
            vc.keys = keysToSend
            vc.sender = self.sender
            vc.delegate = self
            self.table.reloadData()
        }
    }
    
    func photoSentBack(sender: String, keys: [String], photos: [UIImage]) {
        if photos.isEmpty {
            chats[sender] = nil
            chatKeys[sender] = nil
            usernames.removeObject(sender)
        } else {
            chats[sender] = photos
            chatKeys[sender] = keys
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
//            fb
            //yeah we need to add so you can see if you sent someone a snap
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    func showImage(image: UIImage) {
//        var scrollView = UIScrollView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
//        scrollView.backgroundColor = UIColor.blackColor()
//        scrollView.scrollEnabled = false
//        scrollView.pagingEnabled = true
//        
//        var imageView = UIImageView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
//        imageView.image = image
//        imageView.contentMode = UIViewContentMode.ScaleAspectFit
//        scrollView.addSubview(imageView)
//        
//        UIApplication.sharedApplication().keyWindow?.addSubview(scrollView)
//    }
    
    func createOverlay() -> UIView {
        var mainOverlay: UIView = UIView(frame: view.bounds)
        var clearView: UIView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        clearView.opaque = false
        clearView.backgroundColor = UIColor.clearColor()
        mainOverlay.addSubview(clearView)
        
        var button = UIButton(frame: CGRectMake(128, 470, 65, 65))
        button.backgroundColor = UIColor.clearColor()
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.cornerRadius = 65 / 2
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 7
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        mainOverlay.addSubview(button)
        
        var swap = UIButton(frame: CGRectMake(260, 28, 50, 40))
        swap.setTitle("swap", forState: UIControlState.Normal)
        swap.addTarget(self, action: "swap:", forControlEvents: UIControlEvents.TouchUpInside)
        mainOverlay.addSubview(swap)
        
        var close = UIButton(frame: CGRectMake(16, 20, 30, 30))
        close.setTitle("X", forState: UIControlState.Normal)
        close.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
        mainOverlay.addSubview(close)
        
        return mainOverlay
    }
    
    func buttonPressed(sender: UIButton) {
        imagePicker.takePicture()
    }
    
    func swap(sender: UIButton) {
        if imagePicker.cameraDevice == UIImagePickerControllerCameraDevice.Front {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        } else {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        }
    }
    
    func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scalePhoto(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}