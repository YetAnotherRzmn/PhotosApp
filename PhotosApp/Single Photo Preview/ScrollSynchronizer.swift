//
//  ScrollSynchronizer.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/14/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class ScrollSynchronizer: NSObject {
	let preview: PreviewFlowLayout
	let thumbnails: ThumbnailFlowLayout

	var activeIndex = 0

	init(preview: UICollectionView, thumbnails: UICollectionView, sizeForIndex: ((Int) -> CGSize)?) {
		guard
			let previewLayout = preview.collectionViewLayout as? PreviewFlowLayout,
			let thumbnailLayout = thumbnails.collectionViewLayout as? ThumbnailFlowLayout
		else { fatalError("unexpected layout") }
		self.preview = previewLayout
		self.thumbnails = thumbnailLayout

		self.thumbnails.sizeForIndex = sizeForIndex

		super.init()

		bind()
	}

	private func bind() {
		preview.collectionView?.delegate = self
		thumbnails.collectionView?.delegate = self
	}

	private func unbind() {
		preview.collectionView?.delegate = .none
		thumbnails.collectionView?.delegate = .none
	}

	func reload() {
		preview.collectionView?.reloadData()
		thumbnails.collectionView?.reloadData()
	}
}

extension ScrollSynchronizer: UICollectionViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let collection = scrollView as? UICollectionView else { return }
		unbind()
		if collection == preview.collectionView {
			let offset = scrollView.contentOffset.x
			let relativeOffset = offset / preview.itemSize.width / CGFloat(collection.numberOfItems(inSection: 0))
			thumbnails.changeOffset(relative: relativeOffset)
			activeIndex = thumbnails.nearestIndex
		}
		if scrollView == thumbnails.collectionView {
			let index = thumbnails.nearestIndex
			if index != activeIndex {
				activeIndex = index
				let indexPath = IndexPath(row: activeIndex, section: 0)
				preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
			}
		}
		bind()
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		unbind()
		guard collectionView == thumbnails.collectionView else { return }

		activeIndex = indexPath.row

		preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)

		UIView.animate(withDuration: 0.15, animations: { [unowned self] in
			self.thumbnails.collectionView?.scrollToItem(at: indexPath,
														at: .centeredHorizontally,
														animated: false)
		}) { [unowned self] _ in
			self.bind()
		}
	}
}

extension ScrollSynchronizer {
	enum Event {
		case remove(index: IndexPath, completion: (() -> ())?)
	}

	func handle(event: Event) {
		switch event {
		case .remove(let index, let completion):
			delete(at: index, completion: completion)
		}
	}
}

// MARK: - private
extension ScrollSynchronizer {
	func delete(at indexPath: IndexPath, completion: (() -> ())?) {
		unbind()

//		let animatedAspect = thumbnails.sizeForIndex?(indexPath.row).aspectRatio ?? 1
		let nextAspect = thumbnails.sizeForIndex?(indexPath.row).aspectRatio ?? 1
		let diff = thumbnails.itemSize.height * nextAspect - thumbnails.itemSize.width

		let animator = DefaultProgressAnimator(initial: .zero, onProgress: { current, delta in
			self.thumbnails.updates = [
				indexPath: { cell in
					cell.collapsed(by: current)
				}
			]
			self.thumbnails.invalidateLayout()
		})
		animator.setProgress(progress: 1, duration: 0.15, completion: { _ in
			self.thumbnails.updates.removeValue(forKey: indexPath)
			self.thumbnails.phantom = ThumbnailFlowLayout.PhantomItem(width: diff, floatIndex: CGFloat(indexPath.row) + 0.5)
			completion?()
			self.thumbnails.collectionView?.deleteItems(at: [indexPath])
			self.preview.collectionView?.deleteItems(at: [indexPath])
			self.bind()
		})
	}
}
