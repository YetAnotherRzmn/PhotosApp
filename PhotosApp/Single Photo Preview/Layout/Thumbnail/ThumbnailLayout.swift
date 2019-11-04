//
//  ThumbnailLayout.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class ThumbnailLayout: UICollectionViewFlowLayout {

    var config: Configuration
    var dataSource: ((Int) -> CGFloat)
    var layoutHandler: LayoutChangeHandler?

    init(dataSource: ((Int) -> CGSize)?, config: Configuration = Configuration()) {
        self.config = config
        self.dataSource = { index in
            dataSource?(index).aspectRatio ?? config.defaultAspectRatio
        }
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func changeOffset(relative offset: CGFloat) {
        collectionView?.contentOffset.x = collectionViewContentSize.width * offset - farInset
    }
}

// MARK: - shortcuts
extension ThumbnailLayout {

    var itemsCount: Int {
        collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    var offset: CGPoint {
        collectionView?.contentOffset ?? .zero
    }

    var offsetWithoutInsets: CGPoint {
        CGPoint(x: offset.x + farInset, y: offset.y)
    }

    var insets: UIEdgeInsets {
        UIEdgeInsets(top: .zero, left: farInset, bottom: .zero, right: farInset)
    }

    var farInset: CGFloat {
        guard let collection = collectionView else { return .zero }
        return (collection.bounds.width - itemSize.width - config.distanceBetween) / 2
    }

    var relativeOffset: CGFloat {
        guard let collection = collectionView else { return .zero }
        return (collection.contentOffset.x + collection.contentInset.left) / collectionViewContentSize.width
    }

    var nearestIndex: Int {
        let offset = relativeOffset
        let floatingIndex = offset * CGFloat(itemsCount) + 0.5
        return max(0, min(Int(floor(floatingIndex)), itemsCount - 1))
    }
}

// MARK: - UICollectionViewFlowLayout overrides
extension ThumbnailLayout {

    override func prepare() {
        super.prepare()
        if let collectionView = collectionView, let layoutHandler = layoutHandler {
            if layoutHandler.needsUpdateOffset {
                let size = CGSize(
                    width: collectionView.bounds.height * config.defaultAspectRatio,
                    height: collectionView.bounds.height)
                itemSize = size
                collectionView.contentOffset = targetContentOffset(forProposedContentOffset: offset)
                collectionView.contentInset = insets
            }
        }
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

        let cells = (0 ..< itemsCount)
            .map { IndexPath(row: $0, section: 0) }
            .map { cell(for: $0, offsetX: offsetWithoutInsets.x) }
            .map { cell -> Cell in
                if let update = self.config.updates[cell.indexPath] {
                    return update(cell)
                }
                return cell
        }
        return cells.compactMap { $0.attributes(from: self, with: cells) }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collection = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        let cellWithSpacing = itemSize.width + config.distanceBetween
        let relative = (proposedContentOffset.x + collection.contentInset.left) / cellWithSpacing
        let leftIndex = max(0, floor(relative))
        let rightIndex = min(ceil(relative), CGFloat(itemsCount))
        let leftCenter = leftIndex * cellWithSpacing - collection.contentInset.left
        let rightCenter = rightIndex * cellWithSpacing - collection.contentInset.left

        if abs(leftCenter - proposedContentOffset.x) < abs(rightCenter - proposedContentOffset.x) {
            return CGPoint(x: leftCenter, y: proposedContentOffset.y)
        } else {
            return CGPoint(x: rightCenter, y: proposedContentOffset.y)
        }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let targetOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        guard let layoutHandler = layoutHandler else {
            return targetOffset
        }
        let offset = CGFloat(layoutHandler.targetIndex) / CGFloat(itemsCount)
        return CGPoint(
            x: collectionViewContentSize.width * offset - farInset,
            y: targetOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override var collectionViewContentSize: CGSize {
        let width = CGFloat(itemsCount) * (itemSize.width + config.distanceBetween)
        return CGSize(width: width, height: itemSize.height)
    }
}

// MARK: - private
private extension ThumbnailLayout {

    func cell(for index: IndexPath, offsetX: CGFloat) -> Cell {

        let cell = Cell(
            indexPath: index,
            dims: Cell.Dimensions(
                defaultSize: itemSize,
                aspectRatio: dataSource(index.row),
                inset: config.distanceBetween,
                insetAsExpanded: config.distanceBetweenFocused),
            state: .default)

        guard let attribute = cell.attributes(from: self, with: []) else { return cell }

        let cellOffset = attribute.center.x - itemSize.width / 2
        let widthWithOffset = itemSize.width + config.distanceBetween
        if abs(cellOffset - offsetX) < widthWithOffset {
            let expanding = 1 - abs(cellOffset - offsetX) / widthWithOffset
            return cell.updated(by: .expand(expanding * config.expandingRate))
        }
        return cell
    }
}
