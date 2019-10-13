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

    var window: UIWindow?

    func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    	return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
					 configurationForConnecting connectingSceneSession: UISceneSession,
					 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    	return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
