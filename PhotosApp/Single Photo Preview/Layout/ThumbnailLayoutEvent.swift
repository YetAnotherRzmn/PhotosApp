//
//  ThumbnailLayoutEvent.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/20/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailFlowLayout {

	struct Cell: Equatable {
		let aspectRatio: CGFloat
		let indexPath: IndexPath

		let expanding: CGFloat
		let collapsing: CGFloat

		let defaultSize: CGSize
		let defaultInset: CGFloat

		func expanded(by rate: CGFloat) -> Cell {
			return Cell(aspectRatio: aspectRatio,
						indexPath: indexPath,
						expanding: rate,
						collapsing: collapsing,
						defaultSize: defaultSize,
						defaultInset: defaultInset)
		}

		func collapsed(by rate: CGFloat) -> Cell {
			return Cell(aspectRatio: aspectRatio,
						indexPath: indexPath,
						expanding: expanding,
						collapsing: rate,
						defaultSize: defaultSize,
						defaultInset: defaultInset)
		}

		func aspect(by ratio: CGFloat) -> Cell {
			return Cell(aspectRatio: ratio,
						indexPath: indexPath,
						expanding: expanding,
						collapsing: collapsing,
						defaultSize: defaultSize,
						defaultInset: defaultInset)
		}

		func update(attributes: UICollectionViewLayoutAttributes, sideCells: [IndexPath: Cell]) {
			attributes.size = size
			attributes.center = center

			let offset = sideCells.values.reduce(0) { (current, cell) -> CGFloat in
				if attributes.indexPath < cell.indexPath {
					return current - cell.addditionalWidth / 2
				}
				if attributes.indexPath > cell.indexPath {
					return current + cell.addditionalWidth / 2
				}
				return current
			}
			attributes.transform = CGAffineTransform(translationX: offset, y: 0)
		}

		var addditionalWidth: CGFloat {
			(defaultSize.height * aspectRatio - defaultSize.width) * expanding
		}

		var size: CGSize {
			CGSize(width: (defaultSize.width + addditionalWidth) * (1 - collapsing),
				   height: defaultSize.height * (1 - collapsing))
		}

		var center: CGPoint {
			CGPoint(x: CGFloat(indexPath.row) * (defaultSize.width + defaultInset) + defaultSize.width / 2,
					y: defaultSize.height / 2)
		}
	}
}
