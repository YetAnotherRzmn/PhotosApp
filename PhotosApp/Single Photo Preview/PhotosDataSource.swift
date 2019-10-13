//
//  PhotosDataSource.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PhotosDataSource: NSObject {

	lazy var images = loadImages()

	let preview: UICollectionView
	let thumbnails: UICollectionView

	init(preview: UICollectionView, thumbnails: UICollectionView) {
		self.preview = preview
		self.thumbnails = thumbnails

		super.init()

		preview.dataSource = self
		preview.register(PreviewCollectionViewCell.self,
						 forCellWithReuseIdentifier: PreviewCollectionViewCell.reuseId)

		thumbnails.dataSource = self
		thumbnails.register(ThumbnailCollectionViewCell.self,
							forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseId)
	}

	func loadImages() -> [UIImage] {
		guard let urls = Bundle.main.urls(forResourcesWithExtension: .none,
										  subdirectory: "Data") else { fatalError() }
		return urls
			.compactMap{ try? Data(contentsOf: $0) }
			.compactMap(UIImage.init(data:))
	}
}

extension PhotosDataSource: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		var reuseId: String?
		if collectionView == preview {
			reuseId = PreviewCollectionViewCell.reuseId
		}
		if collectionView == thumbnails {
			reuseId = ThumbnailCollectionViewCell.reuseId
		}
		guard let id = reuseId, let cell = collectionView
			.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as? ImageCell else {
			fatalError("")
		}
		cell.imageView.image = images[indexPath.row]
		return cell
	}


}
