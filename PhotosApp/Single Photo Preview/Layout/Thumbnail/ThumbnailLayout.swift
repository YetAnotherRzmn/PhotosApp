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

    var dataSource: ((Int) -> CGFloat)!

    var layoutHandler: LayoutChangeHandler?
    var activeIndex: (() -> Int)!

    init(dataSource: ((Int) -> CGSize)?, config: Configuration = Configuration()) {
        self.config = config
        super.init()
        self.dataSource = { index in
            dataSource?(index).aspectRatio ?? self.config.defaultAspectRatio
        }
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
        if let collectionView = collectionView, let layoutHandler = layoutHandler {
            let heigth = collectionView.bounds.height
            let size = CGSize(width: heigth * config.defaultAspectRatio, height: heigth)
            if size != itemSize {
                itemSize = size
                collectionView.contentInset = UIEdgeInsets(top: 0, left: farInset, bottom: 0, right: farInset)
            }
            if layoutHandler.needsUpdateOffset {
                let offset = collectionView.contentOffset
                collectionView.contentOffset = targetContentOffset(forProposedContentOffset: offset)
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

        guard let collectionView = collectionView else { return nil }
        let offset = collectionView.contentOffset.x + farInset

        let cells = (0 ..< itemsCount)
            .map { IndexPath(row: $0, section: 0) }
            .map { cell(for: $0, offset: offset) }
            .map { cell -> Cell in
                if let update = self.config.updates[cell.indexPath] {
                    return update(cell)
                }
                return cell
        }

        let attrs = cells.compactMap { $0.attributes(from: self, with: cells) }

        return attrs
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collection = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        let cellWithSpacing = itemSize.width + config.distanceBetween
        let relative = (proposedContentOffset.x + collection.contentInset.left) / cellWithSpacing
        let leftIndex = max(0, Int(floor(relative)))
        let rightIndex = min(Int(ceil(relative)), itemsCount)
        let leftCenter = CGFloat(leftIndex) * cellWithSpacing - collection.contentInset.left
        let rightCenter = CGFloat(rightIndex) * cellWithSpacing - collection.contentInset.left

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
        let offset: CGFloat = CGFloat(layoutHandler.targetIndex) / CGFloat(itemsCount)
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

    func cell(for index: IndexPath, offset: CGFloat) -> Cell {

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
        if abs(cellOffset - offset) < widthWithOffset {
            let expanding = 1 - abs(cellOffset - offset) / widthWithOffset
            return cell.updated(by: .expand(expanding * config.expandingRate))
        }
        return cell
    }
}
