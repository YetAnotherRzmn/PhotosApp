//
//  CellState.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/29/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailLayout {

    enum Direction {
        case left
        case right

        var inversed: Direction {
            self == .left ? .right : .left
        }
    }

    struct CellState: Equatable {

        let defaultSize: CGSize
        let aspectRatio: CGFloat
        let indexPath: IndexPath

        let expanding: CGFloat
        let collapsing: CGFloat
        let deleting: CGFloat
        let deletingDirection: Direction
    }
}

// MARK: - layout attributes creation
extension ThumbnailLayout.CellState {

    func attributes(from layout: UICollectionViewFlowLayout,
                    with sideCells: [ThumbnailLayout.CellState]) -> UICollectionViewLayoutAttributes? {
        let attributes = layout.layoutAttributesForItem(at: indexPath)

        attributes?.size = size
        attributes?.alpha = 1 - collapsing
        attributes?.center = center

        attributes?.center.x += sideCells.reduce(0) { (current, cell) -> CGFloat in
            if indexPath < cell.indexPath {
                return current - cell.leftShift
            }
            if indexPath > cell.indexPath {
                return current + cell.rightShift
            }
            return current
        }

        return attributes
    }
}

// MARK: - geometry utils
private extension ThumbnailLayout.CellState {

    var additionalWidth: CGFloat {
        (defaultSize.height * aspectRatio - defaultSize.width) * expanding
    }

    func shift(from direction: ThumbnailLayout.Direction) -> CGFloat {
        switch direction {
        case .left:
            return additionalWidth / 2 * (1 - deleting)
        case .right:
            return additionalWidth / 2 * (1 - deleting) - defaultSize.width * deleting
        }
    }

    var size: CGSize {
        CGSize(width: ceil((defaultSize.width + additionalWidth) * (1 - collapsing)),
               height: defaultSize.height * (1 - collapsing))
    }

    var leftShift: CGFloat {
        shift(from: deletingDirection.inversed)
    }

    var rightShift: CGFloat {
        shift(from: deletingDirection)
    }

    var center: CGPoint {
        CGPoint(x: floor(CGFloat(indexPath.row) * (defaultSize.width /*+ defaultInset*/) + defaultSize.width / 2),
                y: defaultSize.height / 2)
    }
}
