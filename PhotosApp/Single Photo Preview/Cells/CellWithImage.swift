//
//  CellWithImage.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

protocol ImageCell: UICollectionViewCell, SnapView {
    var imageView: UIImageView { get }
}

extension ImageCell {
    func createConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupUI() {
        addSubview(imageView)
        clipsToBounds = true
    }
}
