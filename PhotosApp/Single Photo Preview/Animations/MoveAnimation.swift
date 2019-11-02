//
//  MoveAnimation.swift
//  PhotosApp
//
//  Created by Никита Разумный on 10/27/19.
//  Copyright © 2019 Никита Разумный. All rights reserved.
//

import UIKit

class MoveAnimation: NSObject {
    let preview: PreviewLayout
    let thumbnails: ThumbnailLayout
    let indexPath: IndexPath

    init(thumbnails: ThumbnailLayout, preview: PreviewLayout, index: IndexPath) {
        self.preview = preview
        self.thumbnails = thumbnails
        self.indexPath = index
        super.init()
    }

    func run(with completion: @escaping () -> Void) {
        guard let collectionView = thumbnails.collectionView else { return }
        let fromOffset = collectionView.contentOffset.x
        let floatIndex = CGFloat(indexPath.row)
        let cellWithInsetsWidth = thumbnails.itemSize.width + thumbnails.config.distanceBetween
        let toOffset = floatIndex * cellWithInsetsWidth - thumbnails.farInset

        let fromIndex = IndexPath(row: thumbnails.nearestIndex, section: 0)

        preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        thumbnails.config.expandingRate = .zero
        let animator = Animator(onProgress: { current, _ in
            let offset = fromOffset + (toOffset - fromOffset) * current
            collectionView.contentOffset.x = offset

            self.thumbnails.config.updates[self.indexPath] = {
                $0.updated(by: .expand(current))
            }
            self.thumbnails.config.updates[fromIndex] = {
                $0.updated(by: .expand(1 - current))
            }
        }, easing: .easeInOut)

        animator.animate(duration: 0.3) { _ in
            self.thumbnails.config.expandingRate = 1
            self.thumbnails.config.updates.removeValue(forKey: self.indexPath)
            self.thumbnails.config.updates.removeValue(forKey: fromIndex)
            completion()
        }
    }
}
