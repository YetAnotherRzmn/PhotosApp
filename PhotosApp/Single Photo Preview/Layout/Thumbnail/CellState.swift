//
//  CellState.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/29/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailLayout {
    struct Cell {
        let indexPath: IndexPath

        let dims: Dimensions
        let state: State

        func updated(new state: State) -> Cell {
            return Cell(indexPath: indexPath, dims: dims, state: state)
        }
    }
}

extension ThumbnailLayout.Cell {

    enum Direction {
        case left
        case right

        var inversed: Direction {
            self == .left ? .right : .left
        }
    }

    struct Dimensions {
        let defaultSize: CGSize
        let aspectRatio: CGFloat
        let inset: CGFloat
        let insetAsExpanded: CGFloat
    }

    struct State {
        let expanding: CGFloat
        let collapsing: CGFloat
        let deleting: CGFloat
        let deletingDirection: Direction

        static var `default`: State {
            State(expanding: .zero, collapsing: .zero, deleting: .zero, deletingDirection: .left)
        }
    }
}

// MARK: - layout attributes creation
extension ThumbnailLayout.Cell {

    func attributes(from layout: ThumbnailLayout,
                    with sideCells: [ThumbnailLayout.Cell]) -> UICollectionViewLayoutAttributes? {
        let attributes = layout.layoutAttributesForItem(at: indexPath)

        attributes?.size = size
        attributes?.alpha = 1 - state.collapsing
        attributes?.center = center

        let translate = sideCells.reduce(0) { (current, cell) -> CGFloat in
            if indexPath < cell.indexPath {
                return current - cell.leftShift
            }
            if indexPath > cell.indexPath {
                return current + cell.rightShift
            }
            return current
        }
        attributes?.transform = CGAffineTransform(translationX: translate, y: .zero)

        return attributes
    }
}

// MARK: - geometry utils
private extension ThumbnailLayout.Cell {

    var additionalWidth: CGFloat {
        (dims.defaultSize.height * dims.aspectRatio - dims.defaultSize.width) * state.expanding
    }

    func shift(from direction: ThumbnailLayout.Cell.Direction) -> CGFloat {
        let symmetricShift = (additionalWidth + dims.insetAsExpanded * state.expanding) / 2 * (1 - state.deleting)

        switch direction {
        case .left:
            return symmetricShift
        case .right:
            return symmetricShift - dims.defaultSize.width * state.deleting
        }
    }

    var size: CGSize {
        CGSize(width: ceil((dims.defaultSize.width + additionalWidth) * (1 - state.collapsing)),
               height: dims.defaultSize.height * (1 - state.collapsing))
    }

    var leftShift: CGFloat {
        shift(from: state.deletingDirection.inversed)
    }

    var rightShift: CGFloat {
        shift(from: state.deletingDirection)
    }

    var center: CGPoint {
        CGPoint(x: CGFloat(indexPath.row) * (dims.defaultSize.width + dims.inset) + dims.defaultSize.width / 2,
                y: dims.defaultSize.height / 2)
    }
}
