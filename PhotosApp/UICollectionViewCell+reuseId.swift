//
//  UICollectionViewCell+reuseId.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/12/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension UICollectionViewCell {

    class var reuseId: String {
        return "\(self)"
    }
}
