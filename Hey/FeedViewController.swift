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
        var imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
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
        picker.dismissViewControllerAnimated(true, completion: nil)
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        var message = [
            "sender": PFUser.currentUser()!.username!,
            "pic": imageString
        ]
    
        fb.childByAppendingPath("jack").childByAutoId().setValue(message)
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
}