//
//  AppDelegate.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/11/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let nc = UINavigationController(rootViewController: PhotosViewController())
		nc.setToolbarHidden(false, animated: false)
		window?.rootViewController = nc
		window?.makeKeyAndVisible()
    	return true
    }
}
