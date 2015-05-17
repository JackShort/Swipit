//
//  SearchViewController.swift
//  Hey
//
//  Created by Jack Short on 5/16/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        searchBar = UISearchBar()
        navigationItem.titleView = searchBar
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    }
}