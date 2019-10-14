//
//  PhotosView.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PhotosView: UIView & SnapView {

	let previewCollection:  UICollectionView
	let thumbnailCollection: UICollectionView

	init() {
		previewCollection = UICollectionView(frame: .zero, collectionViewLayout: PreviewFlowLayout())
		thumbnailCollection = UICollectionView(frame: .zero, collectionViewLayout: ThumbnailFlowLayout())
		super.init(frame: .zero)
		setupUI()
		createConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupUI() {
		addSubview(previewCollection)
		addSubview(thumbnailCollection)

		previewCollection.isPagingEnabled = true
		previewCollection.showsVerticalScrollIndicator = false
		previewCollection.showsHorizontalScrollIndicator = false

		thumbnailCollection.showsVerticalScrollIndicator = false
		thumbnailCollection.showsHorizontalScrollIndicator = false
	}

	func createConstraints() {
		thumbnailCollection.snp.makeConstraints {
			$0.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin)
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
			$0.height.equalTo(66)
		}
		previewCollection.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
			$0.bottom.equalTo(thumbnailCollection.snp.top)
		}
	}
}
