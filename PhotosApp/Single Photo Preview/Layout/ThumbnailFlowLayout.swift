//
//  ThumbnailFlowLayout.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension CGSize {
	var aspectRatio: CGFloat {
		return width / height
	}
}

class ThumbnailFlowLayout: UICollectionViewFlowLayout {

	let config = Config()

	var updates: [IndexPath: (Cell) -> (Cell)] = [:]

	var phantom: PhantomItem?

	var updating = false

	var sizeForIndex: ((Int) -> CGSize)?

	var currentAttributes: [IndexPath: Attributes]?
	var cachedAttributes: [IndexPath: Attributes]?

	var deletedItems: [IndexPath]?
	var insertedItems: [IndexPath]?

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
		currentAttributes = [:]
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

	override class var layoutAttributesClass: AnyClass {
		return Attributes.self
	}

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
		cachedAttributes = currentAttributes?.reduce(into: [:], {
			if let copy = $1.value.copy() as? Attributes {
				$0?[$1.key] = copy
			}
		})
		super.prepare()
	}

	override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
		updating = true
		print("log: ", #function)

		insertedItems = []
		deletedItems = []

		updateItems.forEach {
			switch $0.updateAction {
			case .insert:
				$0.indexPathAfterUpdate.map{ insertedItems?.append($0) }
			case .delete:
				$0.indexPathBeforeUpdate.map{ index in
					deletedItems?.append(index)
					updates = [:]
					updates.removeValue(forKey: index)
					updates = updates.reduce(into: [:], { dict, item in
						if item.key < index {
							dict[item.key] = { cell in
								item.value(cell)
							}
						}
						if item.key > index {
							dict[IndexPath(row: item.key.row - 1, section: item.key.section)] = { cell in
								item.value(cell).aspect(by: self.sizeForIndex?(item.key.row - 1).aspectRatio ?? 1.5)
							}
						}
					})
				}
			default:
				break
			}
		}
		phantom = .none
		super.prepare(forCollectionViewUpdates: updateItems)
	}

	override func finalizeCollectionViewUpdates() {
		print("log: ", #function)

		guard let deleted = deletedItems?.first else {
			return
		}
		guard let collectionView = collectionView else { return }

		let aspect = sizeForIndex!(deleted.row).aspectRatio
		let addW = itemSize.height * aspect - itemSize.width

		UIView.animate(withDuration: 0.15) {
			for cell in collectionView.visibleCells {
				guard let index = collectionView.indexPath(for: cell) else { continue }
				if index == deleted {
					cell.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.itemSize.width + addW, height: self.itemSize.height))
					print("!! log: ", cell.layer.animationKeys())
				}
			}
		}
		insertedItems = .none
		deletedItems = .none
		super.finalizeCollectionViewUpdates()
		updating = false
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attrs = super.layoutAttributesForElements(in: rect) else { return nil }

		guard let cv = collectionView else { return nil }
		let offset = cv.contentOffset.x + cv.bounds.width / 2

		let cells: [IndexPath: Cell] = attrs.reduce(into: [:], {
			var cellModel = self.cell(for: $1.indexPath, offset: offset)
			if let update = updates[$1.indexPath] {
				cellModel = update(cellModel)
			}
			$0[$1.indexPath] = cellModel
		})

		attrs.forEach {
			if let phantom = phantom {
				cells[$0.indexPath]?.update(attributes: $0 as! Attributes, sideCells: [:], phantom: phantom)
			} else {
				cells[$0.indexPath]?.update(attributes: $0 as! Attributes, sideCells: cells)
			}

		}
		attrs
			.compactMap{ $0 as? Attributes }
			.filter{ $0.representedElementCategory == .cell }
			.forEach{ self.currentAttributes?[$0.indexPath] = $0 }
		print("========================================")
		print("phantom is \(phantom != nil ? "not nil" : "nil")")
		for attr in attrs {
			print("item \(attr.indexPath.row) \t center \(Int(attr.center.x)) \t width \(Int(attr.size.width))")
		}
		print("========================================")
		return attrs
	}

	override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attrs = deletedItems.map({
			$0.contains(itemIndexPath) ? self.cachedAttributes?[itemIndexPath]?.copy() as? Attributes : .none
		}) else { return .none }
		attrs?.alpha = .zero
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

	func cell(for index: IndexPath, offset: CGFloat) -> Cell {
		let cell = Cell(aspectRatio: sizeForIndex?(index.row).aspectRatio ?? 1.5,
						indexPath: index,
						expanding: 0,
						collapsing: 0,
						defaultSize: itemSize,
						defaultInset: 0)
		if abs(cell.center.x - offset) < itemSize.width {
			let expanding = 1 - abs(cell.center.x - offset) / itemSize.width
			return cell.expanded(by: expanding)
		} else {
			return cell
		}
	}
}


extension ThumbnailFlowLayout {
	class Attributes: UICollectionViewLayoutAttributes {
		var cell: Cell?

		override func copy(with zone: NSZone? = nil) -> Any {
			let copy = super.copy(with: zone) as! Attributes
			copy.cell = cell
			return copy
		}

		override func isEqual(_ object: Any?) -> Bool {
			if let rhs = object as? Attributes {
			   if cell != rhs.cell {
				  return false
			   }
			   return super.isEqual(object)
			} else {
			   return false
			}
		}
	}
}
