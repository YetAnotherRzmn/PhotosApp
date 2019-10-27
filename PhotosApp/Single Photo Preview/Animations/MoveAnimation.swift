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
		guard let collectionView = thumbnails.collectionView else { return }
		let fromOffset = collectionView.contentOffset.x
		let toOffset = CGFloat(indexPath.row) * thumbnails.itemSize.width - thumbnails.farInset

		let fromIndex = IndexPath(row: thumbnails.nearestIndex, section: 0)

		preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
		thumbnails.expandingRate = .zero
		let animator = Animator(onProgress: { current, delta in
			let offset = fromOffset + (toOffset - fromOffset) * current
			collectionView.contentOffset.x = offset

			self.thumbnails.updates[self.indexPath] = {
				$0.updated(by: .expand(current))
			}
			self.thumbnails.updates[fromIndex] = {
				$0.updated(by: .expand(1 - current))
			}
		}, easing: .easeInOut)

		animator.animate(duration: 0.3) { _ in
			self.thumbnails.expandingRate = 1
			self.thumbnails.updates.removeValue(forKey: self.indexPath)
			self.thumbnails.updates.removeValue(forKey: fromIndex)
			completion()
		}
	}
}
