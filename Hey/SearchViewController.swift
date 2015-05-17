//
//  SearchViewController.swift
//  Hey
//
//  Created by Jack Short on 5/16/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var searchBar: UISearchBar!
    var searchedUser: String?
    var userSearchedFor: PFUser?
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchedUser = searchText.lowercaseString
        table.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedUser != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cellId") as! UITableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var but: UIView? = cell.viewWithTag(8)
        
        if but != nil {
            but?.removeFromSuperview()
        }
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let button: UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(screenWidth - 70, 5, 30, 30)
        button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 8
        
        userSearchedFor = searchForUser(searchedUser!)
        var searchedUserExists = false
        
        if self.userSearchedFor != nil {
            searchedUserExists = true
        } else {
            searchedUserExists = false
        }
        
        //This just adds buttons to the cell you have to clear the button then make another or something
        
        if searchedUserExists {
            cell.addSubview(button)
            button.userInteractionEnabled = true
            button.setTitle("+", forState: UIControlState.Normal)
        } else {
            button.removeFromSuperview()
        }
        
        cell.textLabel!.text = searchedUser

        return cell
    }
    
    func searchForUser(username: String) -> PFUser? {
        let query: PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: username)
        var user: PFUser? = query.getFirstObject() as? PFUser
        
        return user
    }
    
    func buttonTapped(sender: UIButton) {
        PFUser.currentUser()!.relationForKey("friends").addObject(userSearchedFor!)
        PFUser.currentUser()!.saveInBackgroundWithBlock { (completed, error) -> Void in
        }
    }
}