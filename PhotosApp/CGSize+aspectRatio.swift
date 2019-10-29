//
//  CGSize+aspectRatio.swift
//  PhotosApp
//
//  Created by Никита Разумный on 10/27/19.
//  Copyright © 2019 Никита Разумный. All rights reserved.
//

import UIKit

extension CGSize {
    var aspectRatio: CGFloat {
        return width / height
    }
}
