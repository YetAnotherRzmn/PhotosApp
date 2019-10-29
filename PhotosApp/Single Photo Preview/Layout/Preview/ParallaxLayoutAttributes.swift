//
//  ParallaxLayoutAttributes.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class ParallaxLayoutAttributes: UICollectionViewLayoutAttributes {
    var parallaxValue: CGFloat?
}

// MARK: - NSCopying
extension ParallaxLayoutAttributes {

    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = super.copy(with: zone) as? ParallaxLayoutAttributes else {
            fatalError("unexpected copy type")
        }
        copy.parallaxValue = self.parallaxValue
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        let attrs = object as? ParallaxLayoutAttributes
        if attrs?.parallaxValue != parallaxValue {
            return false
        }
        return super.isEqual(object)
    }
}
