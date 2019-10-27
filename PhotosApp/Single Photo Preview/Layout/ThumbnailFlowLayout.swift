//
//  ThumbnailFlowLayout.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class ThumbnailFlowLayout: UICollectionViewFlowLayout {

	let config = Config()

	var updates: [IndexPath: CellState.UpdateClosure] = [:]

	var sizeForIndex: ((Int) -> CGSize)?

	var expandingRate: CGFloat = 1

	override init() {
		super.init()
		commonInit()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		scrollDirection = .horizontal
		minimumInteritemSpacing = 0
		minimumLineSpacing = 0
	}

	func changeOffset(relative offset: CGFloat) {
		let inset = collectionView?.contentInset.left ?? .zero
		collectionView?.contentOffset.x = collectionViewContentSize.width * offset - inset
	}
}

extension ThumbnailFlowLayout {
	struct Config {
		let aspectRatio: CGFloat = 0.5
	}
}

// MARK: - shortcuts
extension ThumbnailFlowLayout {

	var farInset: CGFloat {
		guard let collection = collectionView else { return .zero }
		return (collection.bounds.width - itemSize.width) / 2
	}

	var relativeOffset: CGFloat {
		guard let collection = collectionView else { return .zero }
		return (collection.contentOffset.x + collection.contentInset.left) / collectionViewContentSize.width
	}

	var nearestIndex: Int {
		guard let collection = collectionView else { return .zero }
		let offset = relativeOffset
		let items = collection.numberOfItems(inSection: 0)
		let floatingIndex = offset * CGFloat(items) + 0.5
		return max(0, min(Int(floor(floatingIndex)), items - 1))
	}
}

// MARK: - UICollectionViewFlowLayout overrides
extension ThumbnailFlowLayout {

	override func prepare() {
		if let collectionView = collectionView {
			let heigth = collectionView.bounds.height
			let size = CGSize(width: heigth * config.aspectRatio, height: heigth)
			if size != itemSize {
				itemSize = size
				collectionView.contentInset = UIEdgeInsets(top: 0, left: farInset, bottom: 0, right: farInset)
			}
		}
		super.prepare()
	}

	final override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
		super.prepare(forCollectionViewUpdates: updateItems)
		CATransaction.begin()
		CATransaction.setDisableActions(true)
	}

	final override func finalizeCollectionViewUpdates() {
		CATransaction.commit()
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

		guard let cv = collectionView else { return nil }
		let items = cv.numberOfItems(inSection: 0)
		let offset = cv.contentOffset.x + cv.bounds.width / 2

		let cells = (0 ..< items)
			.map{ IndexPath(row: $0, section: 0) }
			.map{ cell(for: $0, offset: offset) }
			.map{ cell -> ThumbnailFlowLayout.CellState in
				if let update = self.updates[cell.indexPath] {
					return update(cell)
				}
				return cell
		}

		let attrs = cells.compactMap{ $0.attributes(from: self, with: cells) }

		return attrs
	}

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
									  withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collection = collectionView else {
			return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
											 withScrollingVelocity: velocity)
		}
		let cellWithSpacing = itemSize.width + minimumInteritemSpacing
		let relative = (proposedContentOffset.x + collection.contentInset.left) / cellWithSpacing
		let leftIndex = max(0, Int(floor(relative)))
		let rightIndex = min(Int(ceil(relative)), collection.numberOfItems(inSection: 0))
		let leftCenter = CGFloat(leftIndex) * cellWithSpacing - collection.contentInset.left
		let rightCenter = CGFloat(rightIndex) * cellWithSpacing - collection.contentInset.left
		
		if abs(leftCenter - proposedContentOffset.x) < abs(rightCenter - proposedContentOffset.x) {
			return CGPoint(x: leftCenter, y: proposedContentOffset.y)
		} else {
			return CGPoint(x: rightCenter, y: proposedContentOffset.y)
		}
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	override var collectionViewContentSize: CGSize {
		guard let collection = collectionView else { return super.collectionViewContentSize }
		let items = CGFloat(collection.numberOfItems(inSection: 0))
		let width = items * itemSize.width + (items - 1) * minimumInteritemSpacing
		return CGSize(width: width, height: itemSize.height)
	}
}

// MARK: - private
private extension ThumbnailFlowLayout {

	func cell(for index: IndexPath, offset: CGFloat) -> CellState {

		let cell = CellState(
			defaultSize: itemSize,
			aspectRatio: sizeForIndex?(index.row).aspectRatio ?? 1.5,
			indexPath: index,
			expanding: .zero,
			collapsing: .zero,
			deleting: .zero,
			deletingDirection: .left)

		guard let attribute = cell.attributes(from: self, with: []) else { return cell }

		let centerX = attribute.center.x
		if abs(centerX - offset) < itemSize.width {
			let expanding = 1 - abs(centerX - offset) / itemSize.width
			return cell.updated(by: .expand(expanding * expandingRate))
		}
		return cell
	}
}
