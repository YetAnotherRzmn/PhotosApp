//
//  DeleteAnimation.swift
//  PhotosApp
//
//  Created by Никита Разумный on 10/27/19.
//  Copyright © 2019 Никита Разумный. All rights reserved.
//

import UIKit

class DeleteAnimation: NSObject {
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

		let collapse = DefaultProgressAnimator(initial: .zero, onProgress: { current, delta in
			self.collapseItem(at: self.indexPath, with: current)
		})

		collapse.setProgress(progress: 1, duration: 0.15, completion: { _ in

			let delete = DefaultProgressAnimator(initial: .zero, onProgress: { current, delta in
				self.deleteItem(at: self.indexPath, with: current)
			})

			delete.setProgress(progress: 1, duration: 0.15) { _ in
				self.thumbnails.updates = [:]
				completion()
			}
		})
	}
}

private extension DeleteAnimation {

	func collapseItem(at indexPath: IndexPath, with rate: CGFloat) {
		let update: ThumbnailFlowLayout.CellState.Update = .collapse(rate)
		let previousUpdate = self.thumbnails.updates[indexPath]
		self.thumbnails.updates[indexPath] = { update.closure(previousUpdate?($0) ?? $0) }
		self.thumbnails.invalidateLayout()
	}

	func deleteItem(at indexPath: IndexPath, with rate: CGFloat) {
		guard let collectionView = thumbnails.collectionView else { return }

		let direction = { () -> ThumbnailFlowLayout.CellState.Direction in
			if indexPath.row + 1 >= collectionView.numberOfItems(inSection: 0) {
				return .left
			} else {
				return .right
			}
		}()

		let expandingIndexPath = { () -> IndexPath in
			switch direction {
			case .left:
				return IndexPath(row: indexPath.row - 1, section: 0)
			case .right:
				return IndexPath(row: indexPath.row + 1, section: 0)
			}
		}()
		deleteItem(at: indexPath, with: rate, expandingIndexPath: expandingIndexPath, animationDirection: direction)
	}

	func deleteItem(
		at indexPath: IndexPath,
		with rate: CGFloat,
		expandingIndexPath: IndexPath,
		animationDirection: ThumbnailFlowLayout.CellState.Direction) {

		let delete: ThumbnailFlowLayout.CellState.Update = .delete(rate, animationDirection)
		let expand: ThumbnailFlowLayout.CellState.Update = .expand(rate)

		zip([indexPath, expandingIndexPath], [delete, expand]).forEach { index, update in
			let previousUpdate = self.thumbnails.updates[index]
			self.thumbnails.updates[index] = { update.closure(previousUpdate?($0) ?? $0) }
		}
		self.thumbnails.invalidateLayout()
	}

}
