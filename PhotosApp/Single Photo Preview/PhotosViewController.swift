//
//  ViewController.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/11/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
	var dataSource: PhotosDataSource?

	var contentView: PhotosView {
		return view as! PhotosView
	}

	override func loadView() {
		view = PhotosView()
		dataSource = PhotosDataSource(preview: contentView.previewCollection,
									  thumbnails: contentView.thumbnailCollection)
		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .action, target: .none, action: .none),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none),
			UIBarButtonItem(barButtonSystemItem: .trash, target: .none, action: .none)
		]
	}
}
