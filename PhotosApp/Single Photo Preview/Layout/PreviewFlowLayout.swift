//
//  PreviewFlowLayout.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PreviewFlowLayout: UICollectionViewFlowLayout {

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
}
