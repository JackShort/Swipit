//
//  NavigationControllerDelegate.swift
//  Hey
//
//  Created by Jack Short on 5/12/15.
//  Copyright (c) 2015 JackIV. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator()
    }
}
