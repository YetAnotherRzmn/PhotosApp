//
//  SceneDelegate.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/11/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func scene(_ scene: UIScene,
			   willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {
    	guard let windowScene = (scene as? UIWindowScene) else { return }
		let nc = UINavigationController(rootViewController: PhotosViewController())
		nc.setToolbarHidden(false, animated: false)
		window?.rootViewController = nc
		window?.makeKeyAndVisible()
		window?.windowScene = windowScene
    }
}
