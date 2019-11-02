//
//  Configuration.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/29/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailLayout {

    struct Configuration {
        let maxAspectRatio: CGFloat = 5
        let minAspectRatio: CGFloat = 0.2
        let defaultAspectRatio: CGFloat = 0.5

        let distanceBetween: CGFloat = 4
        let distanceBetweenFocused: CGFloat = 20

        var expandingRate: CGFloat = 1
        var updates: [IndexPath: CellUpdate] = [:]
    }
}
