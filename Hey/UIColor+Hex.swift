//
//  UIColor+Hex.swift
//  HoppyToad
//
//  Created by Jack Short on 2/16/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}