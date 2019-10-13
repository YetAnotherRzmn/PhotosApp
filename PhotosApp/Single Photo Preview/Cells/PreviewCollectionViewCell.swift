//
//  PreviewCollectionViewCell.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import SnapKit

class PreviewCollectionViewCell: UICollectionViewCell & ImageCell {

	private(set) var imageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		createConstraints()
		imageView.contentMode = .scaleAspectFit
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
