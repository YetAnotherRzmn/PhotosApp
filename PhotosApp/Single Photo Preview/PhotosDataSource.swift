//
//  PhotosDataSource.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import Require

class PhotosDataSource: NSObject {

    lazy var images = loadImages()

    let preview: UICollectionView
    let thumbnails: UICollectionView

    init(preview: UICollectionView, thumbnails: UICollectionView) {
        self.preview = preview
        self.thumbnails = thumbnails

        super.init()

        preview.dataSource = self
        preview.register(
            PreviewCollectionViewCell.self,
            forCellWithReuseIdentifier: PreviewCollectionViewCell.reuseId)

        thumbnails.dataSource = self
        thumbnails.register(
            ThumbnailCollectionViewCell.self,
            forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseId)
    }

    var urls: [URL] {
        Bundle.main.urls(
            forResourcesWithExtension: .none,
            subdirectory: "Data").require(hint: "No test data found.")
    }

    func loadImages() -> [UIImage] {
        return urls
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap(UIImage.init(data:))
    }

    func randomImage() -> UIImage {
        return Set(loadImages()).randomElement().require(hint: "No test data found.")
    }
}

extension PhotosDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reuseId: String?
        if collectionView == preview {
            reuseId = PreviewCollectionViewCell.reuseId
        }
        if collectionView == thumbnails {
            reuseId = ThumbnailCollectionViewCell.reuseId
        }
        let cell = reuseId.flatMap {
            collectionView.dequeueReusableCell(
                withReuseIdentifier: $0,
                for: indexPath) as? ImageCell
        }
        cell?.imageView.image = images[indexPath.row]
        return cell.require(hint: "Unexpected cell type.")
    }

}
