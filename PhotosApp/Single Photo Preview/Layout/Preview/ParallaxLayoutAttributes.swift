//
//  ParallaxLayoutAttributes.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import Require

class ParallaxLayoutAttributes: UICollectionViewLayoutAttributes {
    var parallaxValue: CGFloat?
}

// MARK: - NSCopying
extension ParallaxLayoutAttributes {

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as? ParallaxLayoutAttributes
        copy?.parallaxValue = self.parallaxValue
        return copy.require(hint: "Unexpected copy type.")
    }

    override func isEqual(_ object: Any?) -> Bool {
        let attrs = object as? ParallaxLayoutAttributes
        if attrs?.parallaxValue != parallaxValue {
            return false
        }
        return super.isEqual(object)
    }
}
