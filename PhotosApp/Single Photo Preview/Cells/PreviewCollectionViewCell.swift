//
//  PreviewCollectionViewCell.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class PreviewCollectionViewCell: UICollectionViewCell & ImageCell {

	private(set) var imageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		createConstraints()
		imageView.contentMode = .scaleAspectFit
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		guard let imageSize = imageView.image?.size else { return }
		let imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: bounds)

		let path = UIBezierPath(rect: imageRect)
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		layer.mask = shapeLayer
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		guard let attrs = layoutAttributes as? ParallaxLayoutAttributes else {
			return super.apply(layoutAttributes)
		}
		let parallaxValue = attrs.parallaxValue ?? 0
		let transition = -(bounds.width * 0.3 * parallaxValue)
		imageView.transform = CGAffineTransform(translationX: transition, y: .zero)
	}
}
