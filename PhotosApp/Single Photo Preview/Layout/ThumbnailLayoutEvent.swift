//
//  ThumbnailLayoutEvent.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/20/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailFlowLayout {

	struct CellState: Equatable {
		typealias UpdateClosure = (CellState) -> (CellState)

		enum Direction {
			case left
			case right

			var inversed: Direction {
				self == .left ? .right : .left
			}
		}

		let defaultSize: CGSize
		let aspectRatio: CGFloat
		let indexPath: IndexPath

		let expanding: CGFloat
		let collapsing: CGFloat
		let deleting: CGFloat
		let deletingDirection: Direction
	}
}

// MARK: - api
extension ThumbnailFlowLayout.CellState {

	enum Update {
		case expand(CGFloat)
		case collapse(CGFloat)
		case delete(CGFloat, Direction)

		var closure: UpdateClosure {
			return { $0.updated(by: self) }
		}
	}

	func attributes(from layout: UICollectionViewFlowLayout,
					with sideCells: [ThumbnailFlowLayout.CellState]) -> UICollectionViewLayoutAttributes? {
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

	func updated(by update: Update) -> ThumbnailFlowLayout.CellState {
		switch update {
		case .collapse(let rate):
			return collapsed(by: rate)
		case .expand(let rate):
			return expanded(by: rate)
		case .delete(let rate, let direction):
			return deleting(by: rate, with: direction)
		}
	}
}

// MARK: - private
private extension ThumbnailFlowLayout.CellState {

	var additionalWidth: CGFloat {
		(defaultSize.height * aspectRatio - defaultSize.width) * expanding
	}

	func shift(from direction: Direction) -> CGFloat {
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

// MARK: - builders
private extension ThumbnailFlowLayout.CellState {

	func expanded(by rate: CGFloat) -> ThumbnailFlowLayout.CellState {
		return ThumbnailFlowLayout.CellState(
			defaultSize: defaultSize,
			aspectRatio: aspectRatio,
			indexPath: indexPath,
			expanding: rate,
			collapsing: collapsing,
			deleting: deleting,
			deletingDirection: deletingDirection)
	}

	func collapsed(by rate: CGFloat) -> ThumbnailFlowLayout.CellState {
		return ThumbnailFlowLayout.CellState(
			defaultSize: defaultSize,
			aspectRatio: aspectRatio,
			indexPath: indexPath,
			expanding: expanding,
			collapsing: rate,
			deleting: deleting,
			deletingDirection: deletingDirection)
	}

	func aspect(by ratio: CGFloat) -> ThumbnailFlowLayout.CellState {
		return ThumbnailFlowLayout.CellState(
			defaultSize: defaultSize,
			aspectRatio: ratio,
			indexPath: indexPath,
			expanding: expanding,
			collapsing: collapsing,
			deleting: deleting,
			deletingDirection: deletingDirection)
	}

	func deleting(by rate: CGFloat,
				  with direction: ThumbnailFlowLayout.CellState.Direction) -> ThumbnailFlowLayout.CellState {
		return ThumbnailFlowLayout.CellState(
			defaultSize: defaultSize,
			aspectRatio: aspectRatio,
			indexPath: indexPath,
			expanding: expanding,
			collapsing: collapsing,
			deleting: rate,
			deletingDirection: direction)
	}
}
