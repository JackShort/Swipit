//
//  ViewController.swift
//  Hey
//
//  Created by Jack Short on 11/25/14.
//  Copyright (c) 2014 Shyft. All rights reserved.
//

/*
What we gotta do next time
1. move that shitty ass logout button somewhere fucking else
2. display friends list with user on top
3. allow user to add photos to his thingy
4. put the photo on the messaging thing
*/

import Foundation
import Parse

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var fb = Firebase(url: "https://hey-chat.firebaseio.com/")
    var friendsLoaded = false
    var friends: [PFUser] = [PFUser]()
    var friendsUsernames: [String] = [String]()
    var peopleChattedWith: [PFUser] = [PFUser]()
    
    var friendDict: [String: [PFUser]] = [String: [PFUser]]()
    var friendSectionTitles: [String] = [String]()
    var tableViewSectionTitles: [String] = [String]()
    
    var friendRef: Firebase = Firebase()
    var firebase: Firebase = Firebase(url: "https://hey-chat.firebaseio.com/")
    
    var chosen: [PFUser] = [PFUser]()
    var indicesSelected: [NSIndexPath] = [NSIndexPath]()
    
    var angle: Double = 360
    var keyboardShown = false
    
    var searchedUsername: String = ""
    var searchedUser: PFUser?
    
    var scrollView: UIScrollView!
    var picker: UIImagePickerController!
    var sendTo: String?
    
    var cellId = "cellId"
    
    let GREEN: UIColor = UIColor(red: 0, green: 0.902, blue: 0.463, alpha: 1)
    let BLUE: UIColor = UIColor(red: 0.259, green: 0.647, blue: 0.961, alpha: 1)
    let RED: UIColor = UIColor(red: 0.914, green: 0.118, blue: 0.388, alpha: 2)
    let HEIGHT: CGFloat = 70
    let SEARCH_HEIGHT: CGFloat = 50
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register Class For cell reuse
        self.table.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
//        self.table.registerClass(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: "searchCell")
        
        //scrollview stuff
//        self.scrollView.delegate = self
        
        //table stuff
//        self.table.rowHeight = 70
//        self.table.separatorStyle = UITableViewCellSeparatorStyle.None
//        self.table.sectionIndexColor = UIColor.blackColor()
//        self.table.sectionIndexBackgroundColor = UIColor.clearColor()
//        self.table.sectionIndexTrackingBackgroundColor = UIColor(white: 0.75, alpha: 0.5)
//        
//        //Color stuff
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.486, green: 0.302, blue: 1, alpha: 1)
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        
//        //navigation title
//        var titleLabel = UILabel(frame: CGRect.zeroRect)
//        titleLabel.textColor = UIColor.whiteColor()
//        titleLabel.font = UIFont(name: "RobotoCondensed-Bold", size: 25)
//        titleLabel.textAlignment = .Center
//        titleLabel.text = "Say Hey"
//        titleLabel.sizeToFit()
//        self.navigationItem.titleView = titleLabel
//        
//        //call the load friends stuff
//        self.friendRef = Firebase(url: "https://hey-chat.firebaseio.com/users").childByAppendingPath(PFUser.currentUser().username).childByAppendingPath("friends")
        
        loadFriends()
        
        var doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        table.addGestureRecognizer(doubleTap)
        
        picker = UIImagePickerController()
        picker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.delegate = self
        
        var title = UILabel()
        title.backgroundColor = UIColor.clearColor()
        title.font = UIFont(name: "Helvetica Neue", size: 20)
        title.shadowColor = UIColor(white: 1, alpha: 1)
        title.shadowOffset = CGSizeMake(0.0, 1.0);
        title.textColor = UIColor.whiteColor()
        title.text = "Friends"
        navigationItem.titleView = title
        title.sizeToFit()
        
        navigationController?.navigationBar.barTintColor = UIColor(hex: 0x36465d, alpha: 1)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor(hex: 0xFFFFFF, alpha: 1)
        
        // you know what this does
        self.tableViewSectionTitles = ["+","me","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        
        //keyboard setup
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        prefersStatusBarHidden()
//        super.viewWillAppear(animated)
//        
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.486, green: 0.302, blue: 1, alpha: 1)
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //loading friends functions
    func loadFriends() {
        var relation = PFUser.currentUser()!.relationForKey("friends")
        relation.query()!.findObjectsInBackgroundWithBlock { (users, error) -> Void in
            var users = users as! [PFUser]
            self.friends = users
            self.table.reloadData()
//            self.sortFriends()
        }
    }
    
//    func sortFriends() {
//        self.friends.sort{ $0.username!.localizedCaseInsensitiveCompare($1.username!) == NSComparisonResult.OrderedAscending }
//        
//        self.friendDict = [String : [PFUser]]()
//        self.friendSectionTitles = [String]()
//        for i in self.friends {
//            if i.username == PFUser.currentUser()!.username && friendDict["me"] == nil{
//                friendDict["me"] = [i]
//                self.friendSectionTitles.insert("me", atIndex: 0)
//            } else if (friendDict[i.username[0]] != nil) && (i.username != PFUser.currentUser().username) {
//                friendDict[i.username[0].uppercaseString] = [i]
//                self.friendSectionTitles.append(i.username[0].uppercaseString)
//            } else {
//                if !contains(friendDict[i.username[0].uppercaseString]!, i) && PFUser.currentUser().username != i.username{
//                    friendDict[i.username[0].uppercaseString]?.append(i)
//                }
//            }
//        }
//        
//        friendDict["+"] = []
//        self.friendSectionTitles.insert("+", atIndex: 0)
//        self.friendsLoaded = true
//        self.table.reloadData()
//    }
    
    //User interaction methods
    func searchForUser (userName: String) -> PFUser? {
        let query: PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: userName)
        //in background for async
        var user: PFUser? = query.getFirstObject() as? PFUser
        
        return user
    }
    
    func isFriend(username: String) -> Bool {
        if contains(self.friendsUsernames, username) {
            return true
        }
        
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
//    func removeFriend(sender: UIButton!) {
//        if searchedUser?.username == PFUser.currentUser()!.username {
//            let alertController = UIAlertController(title: "Umm", message: "You cannot unfriend yourself... that makes a lonely life", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
//            self.presentViewController(alertController, animated: true, completion: nil)
//        } else {
//            PFUser.currentUser()!.relationForKey("friends").removeObject(searchedUser!)
//            PFUser.currentUser()!.saveInBackgroundWithBlock({ (completed: Bool, error: NSError!) -> Void in
//                var username = self.searchedUsername
//                var friendsArray = self.friendsUsernames
//                friendsArray.removeAtIndex(find(friendsArray, self.searchedUsername)!)
//                self.friendRef.setValue(friendsArray)
//                println("Removed user: \(username)")
//                sender.setTitle("+", forState: .Normal)
//                sender.removeTarget(self, action: "removeFriend:", forControlEvents: UIControlEvents.TouchUpInside)
//                sender.addTarget(self, action: "addFriend:", forControlEvents: UIControlEvents.TouchUpInside)
//            })
//        }
//    }
    
//    func addFriend(sender: UIButton!) {
//        PFUser.currentUser().relationForKey("friends").addObject(searchedUser)
//        PFUser.currentUser().saveInBackgroundWithBlock { (completed: Bool, error: NSError!) -> Void in
//            var username = self.searchedUsername
//            self.friendRef.childByAppendingPath(String(self.friendsUsernames.count)).setValue(username)
//            println("Added user: \(username) as friend")
//            sender.setTitle("h", forState: .Normal)
//            sender.removeTarget(self, action: "addFriend:", forControlEvents: UIControlEvents.TouchUpInside)
//            sender.addTarget(self, action: "removeFriend:", forControlEvents: UIControlEvents.TouchUpInside)
//        }
//    }
    
    
//    func direct(sender: UIButton!) {
//        //        println("tapped")
//        for user in self.chosen {
//            var pushQuery: PFQuery = PFInstallation.query()
//            
//            pushQuery.whereKey("user", equalTo: user)
//            
//            PFPush.sendPushMessageToQueryInBackground(pushQuery, withMessage: "\(PFUser.currentUser().username) says Hey! Say Hey back!", block: nil)
//        }
//        
//        createConversationWithUser()
//        
//        for i in self.indicesSelected {
//            self.tableView(self.table, didSelectRowAtIndexPath: i)
//        }
//    }
    
    func keyboardDidShow(notif: NSNotification) {
        self.keyboardShown = true
    }
    
    func keyboardDidHide(notif: NSNotification) {
        self.keyboardShown = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Scroll View functions
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.keyboardShown == true {
            self.view.endEditing(true)
        }
    }
    
    //table functions
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.friendSectionTitles[section] == "+" {
//            return 1
//        }
//        
//        return self.friendDict[friendSectionTitles[section]]!.count
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.friendSectionTitles[section]
//    }
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        var header: UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
//        header.textLabel.textColor = UIColor(red: 0.486, green: 0.302, blue: 1, alpha: 1)
        
//        header.contentView.backgroundColor = UIColor.whiteColor()
//    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return SEARCH_HEIGHT
//        } else {
//            return HEIGHT
//        }
//    }
    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
//        return self.tableViewSectionTitles
//    }
    
//    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        var location: Int? = find(self.friendSectionTitles, title)
//        
//        if location != nil {
//            return location!
//        }
//        
//        return -1
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 70
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        if indexPath.row == 0 {
//            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! UITableViewCell
//            
//            
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
////            cell.mainTextBox.delegate = self
////            cell.mainTextBox.userInteractionEnabled = true
////            cell.mainTextBox.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
//            
//            return cell
//        }
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
        
        cell.textLabel?.text = friends[indexPath.row].username
        
//        let screenSize: CGRect = UIScreen.mainScreen().bounds
//        let screenWidth = screenSize.width
//        let screenHeight = screenSize.height
//        
//        var sectionTitle = self.friendSectionTitles[indexPath.section]
//        var friendArray: [PFUser]! = friendDict[sectionTitle]
//        var friend = friendArray[indexPath.row]
        
//        cell!.user = friend
//        cell!.mainLabel.text = friend.username.uppercaseString
//        
//        if indexPath.row % 2 == 0 {
//            cell!.defaultColor = BLUE
//        } else {
//            cell!.defaultColor = RED
//        }
//        
//        if contains(self.chosen, friend) {
//            cell!.colorOfText = GREEN
//            
//            var backgroundView = UIView(frame: cell!.frame)
//            cell?.backgroundView = backgroundView
//        } else {
//            cell!.colorOfText = cell!.defaultColor
//            
//            var backgroundView = UIView(frame: cell!.frame)
//            cell?.backgroundView = backgroundView
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        if indexPath.section != 0 {
//            var cell: FriendTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FriendTableViewCell
//            
//            if cell.user?.username != PFUser.currentUser().username {
//                if find(self.chosen, cell.user!) == nil {
//                    cell.colorOfText = GREEN
//                    
//                    self.chosen.append(cell.user!)
//                    self.indicesSelected.append(indexPath)
//                } else {
//                    cell.colorOfText = cell.defaultColor
//                    
//                    self.chosen.removeAtIndex(find(self.chosen, cell.user!)!)
//                    self.indicesSelected.removeAtIndex(find(self.indicesSelected, indexPath)!)
//                }
//                
//                if self.chosen.count == 0 {
//                    fadeEverythingOut()
//                } else if self.chosen.count == 1 {
//                    fadeIn(self.floatButton, time: 0.5, alpha: 1)
//                }
//            } else {
//                let alertController = UIAlertController(title: "Umm", message: "You cannot message yourself... there is no fun in that", preferredStyle: .Alert)
//                alertController.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
//                self.presentViewController(alertController, animated: true, completion: nil)
//            }
//        }
    }
    
    func doubleTap(sender: UITapGestureRecognizer) {
        if UIGestureRecognizerState.Ended == sender.state {
            var point = sender.locationInView(sender.view)
            var indexPath: NSIndexPath = table.indexPathForRowAtPoint(point)!
            var cell = table.cellForRowAtIndexPath(indexPath)
            sendTo = cell!.textLabel!.text!
            
            picker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.showsCameraControls = false
            picker.delegate = self
            
            var translate = CGAffineTransformMakeTranslation(0.0, 71.0)
            picker.cameraViewTransform = translate;
            
            var scale = CGAffineTransformScale(translate, 1.333333, 1.333333)
            picker.cameraViewTransform = scale;
            
            var overlay = createOverlay()
            picker.cameraOverlayView = overlay
            
            presentViewController(picker, animated: true, completion: nil)
        }
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
    
        println(sendTo)
        fb.childByAppendingPath(sendTo).childByAutoId().setValue(message)
    }
    
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
        picker.takePicture()
    }
    
    func swap(sender: UIButton) {
        if picker.cameraDevice == UIImagePickerControllerCameraDevice.Front {
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        } else {
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
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
