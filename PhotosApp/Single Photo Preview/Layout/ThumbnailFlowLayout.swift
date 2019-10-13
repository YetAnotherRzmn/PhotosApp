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

	override init() {
		super.init()
		commonInit()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		scrollDirection = .horizontal
		minimumInteritemSpacing = 4
	}
}

extension ThumbnailFlowLayout {
	struct Config {
		let aspectRatio: CGFloat = 0.5
	}
}

// MARK: - UICollectionViewFlowLayout overrides
extension ThumbnailFlowLayout {

	var farInset: CGFloat {
		guard let collection = collectionView else { return .zero }
		return (collection.bounds.width - itemSize.width) / 2
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	override func prepare() {
		if let collectionView = collectionView {
			let heigth = collectionView.bounds.height
			let size = CGSize(width: heigth * config.aspectRatio, height: heigth)
			if size != itemSize {
				itemSize = size
				sectionInset = UIEdgeInsets(top: 0, left: farInset, bottom: 0, right: farInset)
				invalidateLayout()
			}
		}
		super.prepare()
	}
}
