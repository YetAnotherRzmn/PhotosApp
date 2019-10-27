//
//  ScrollAnimation.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/27/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class ScrollAnimation: NSObject {
	let preview: PreviewFlowLayout
	let thumbnails: ThumbnailFlowLayout
	let type: Type
	
	init(thumbnails: ThumbnailFlowLayout, preview: PreviewFlowLayout, type: Type) {
		self.preview = preview
		self.thumbnails = thumbnails
		self.type = type
		super.init()
	}

	func run(completion: @escaping () -> ()) {
		let toValue: CGFloat = self.type == .beign ? 0 : 1
		let currentExpanding = thumbnails.expandingRate
		let duration = TimeInterval(0.15 * abs(currentExpanding - toValue))

		let animator = Animator(onProgress:  { current, delta in
			let rate = currentExpanding + (toValue - currentExpanding) * current
			self.thumbnails.expandingRate = rate
			self.thumbnails.invalidateLayout()
		}, easing: .easeInOut)

		animator.animate(duration: duration) { _ in
			completion()
		}
	}
}

extension ScrollAnimation {

	enum `Type` {
		case beign
		case end
	}
}
