//
//  PhotosView.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PhotosView: UIView & SnapView {

    let previewCollection: UICollectionView
    let thumbnailCollection: UICollectionView
    let synchronizer: ScrollSynchronizer

    let debugCenterLine: UIView

    init(sizeForIndex: ((Int) -> CGSize)?) {
        let previewLayout = PreviewLayout()
        let thumbnailLayout = ThumbnailLayout(dataSource: sizeForIndex)
        previewCollection = UICollectionView(frame: .zero, collectionViewLayout: previewLayout)
        thumbnailCollection = UICollectionView(frame: .zero, collectionViewLayout: thumbnailLayout)
        thumbnailCollection.decelerationRate = .fast
        synchronizer = ScrollSynchronizer(
            preview: previewLayout,
            thumbnails: thumbnailLayout)
        debugCenterLine = UIView()
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
        addSubview(debugCenterLine)

        let backgroundColor = UIColor(named: "SinglePhotoBackground")

        debugCenterLine.backgroundColor = .red

        previewCollection.isPagingEnabled = true
        previewCollection.showsVerticalScrollIndicator = false
        previewCollection.showsHorizontalScrollIndicator = false
        previewCollection.backgroundColor = backgroundColor

        thumbnailCollection.showsVerticalScrollIndicator = false
        thumbnailCollection.showsHorizontalScrollIndicator = false
        thumbnailCollection.backgroundColor = backgroundColor
    }

    func createConstraints() {
        debugCenterLine.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
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

    var indexInFocus: Int {
        return synchronizer.activeIndex
    }
}
