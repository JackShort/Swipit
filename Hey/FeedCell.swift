//
//  FeedCell.swift
//  Hey
//
//  Created by Jack Short on 5/6/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import Foundation
import Parse

class FeedCell: UITableViewCell {
    var photo: UIImage?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}