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
			self.thumbnails.collectionView?.scrollToItem(
				at: indexPath,
				at: .centeredHorizontally,
				animated: false)
		}) { [unowned self] _ in
			self.bind()
		}
	}
}

extension ScrollSynchronizer {
	enum Event {
		case remove(index: IndexPath, dataSourceUpdate: () -> (), completion: (() -> ())?)
		case move(index: IndexPath, completion: (() -> ())?)
	}

	func handle(event: Event) {
		switch event {
		case .remove(let index, let update, let completion):
			delete(at: index, dataSourceUpdate: update, completion: completion)
		case .move(let index, let completion):
			move(to: index, completion: completion)
		}
	}
}

// MARK: -
private extension ScrollSynchronizer {

	func delete(
		at indexPath: IndexPath,
		dataSourceUpdate: @escaping () -> (),
		completion: (() -> ())?) {

		unbind()
		DeleteAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
			dataSourceUpdate()
			self.thumbnails.collectionView?.deleteItems(at: [indexPath])
			self.preview.collectionView?.deleteItems(at: [indexPath])
			self.bind()
			completion?()
		}
	}

	func move(to indexPath: IndexPath, completion: (() -> ())?) {

		unbind()
		MoveAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
			self.bind()
		}
	}
}
