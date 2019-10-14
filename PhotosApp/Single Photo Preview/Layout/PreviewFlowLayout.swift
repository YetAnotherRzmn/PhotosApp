//
//  PreviewFlowLayout.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PreviewFlowLayout: UICollectionViewFlowLayout {

	let offsetBetweenCells: CGFloat = 44

	override init() {
		super.init()
		commonInit()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		scrollDirection = .horizontal
		minimumLineSpacing = 0
		minimumInteritemSpacing = 0
	}
}

// MARK: - UICollectionViewFlowLayout overrides
extension PreviewFlowLayout {

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	override class var layoutAttributesClass: AnyClass {
		return ParallaxLayoutAttributes.self
	}

	override func prepare() {
		if let collectionView = collectionView {
			let size = collectionView.bounds.size
			if size != itemSize {
				itemSize = size
				invalidateLayout()
			}
		}
		super.prepare()
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return super.layoutAttributesForElements(in: rect)?
			.compactMap{ $0.copy() as? ParallaxLayoutAttributes }
			.compactMap(prepareAttributes)
	}

	private func prepareAttributes(attributes: ParallaxLayoutAttributes) -> ParallaxLayoutAttributes {
		guard let collectionView = self.collectionView else { return attributes }

		let width = itemSize.width
		let centerX = width / 2
		let distanceToCenter = attributes.center.x - collectionView.contentOffset.x
		let relativeDistanceToCenter = (distanceToCenter - centerX) / width

		if abs(relativeDistanceToCenter) >= 1 {
			attributes.parallaxValue = .none
			attributes.transform = .identity
		} else {
			attributes.parallaxValue = relativeDistanceToCenter
			attributes.transform = CGAffineTransform(translationX: relativeDistanceToCenter * offsetBetweenCells, y: 0)
		}
		return attributes
	}
}
