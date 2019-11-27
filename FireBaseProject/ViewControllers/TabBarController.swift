//
//  TabBarController.swift
//  FireBaseProject
//
//  Created by Phoenix McKnight on 11/25/19.
//  Copyright © 2019 Phoenix McKnight. All rights reserved.
//

import Foundation
import UIKit

class TabBarController:UITabBarController {
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMainTabBarController()
    }
    
    
        private func createMainTabBarController() {
            let navController = UINavigationController(rootViewController: FeedViewController())

            navController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)
            let createVC = UINavigationController(rootViewController: CreatePhotoVC())
            createVC.tabBarItem = UITabBarItem(title: "Create", image: UIImage(systemName: "plus.square"), tag: 1)
         
            viewControllers = [navController,createVC]
        }

    
}
