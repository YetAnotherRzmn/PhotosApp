//
//  MoveAnimation.swift
//  PhotosApp
//
//  Created by Никита Разумный on 10/27/19.
//  Copyright © 2019 Никита Разумный. All rights reserved.
//

import UIKit

class MoveAnimation: NSObject {
	let preview: PreviewFlowLayout
	let thumbnails: ThumbnailFlowLayout
	let indexPath: IndexPath

	init(thumbnails: ThumbnailFlowLayout, preview: PreviewFlowLayout, index: IndexPath) {
		self.preview = preview
		self.thumbnails = thumbnails
		self.indexPath = index
		super.init()
	}

	func run(with completion: @escaping () -> ()) {

	}
}
