//
//  DeleteAnimation.swift
//  PhotosApp
//
//  Created by Никита Разумный on 10/27/19.
//  Copyright © 2019 Никита Разумный. All rights reserved.
//

import UIKit

class DeleteAnimation: NSObject {
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

        let collapse = Animator(onProgress: { current, _ in
            self.collapseItem(at: self.indexPath, with: current)
        })

        collapse.animate(duration: 0.15) { _ in

            let delete = Animator(onProgress: { current, _ in
                self.deleteItem(at: self.indexPath, with: current)
            })

            delete.animate(duration: 0.15) { _ in
                self.thumbnails.config.updates = [:]
                completion()
            }
        }
    }
}

private extension DeleteAnimation {

    func collapseItem(at indexPath: IndexPath, with rate: CGFloat) {
        let update: ThumbnailLayout.UpdateType = .collapse(rate)
        let previousUpdate = thumbnails.config.updates[indexPath]
        thumbnails.config.updates[indexPath] = update.closure + previousUpdate
        thumbnails.invalidateLayout()
    }

    func deleteItem(at indexPath: IndexPath, with rate: CGFloat) {
        guard let collectionView = thumbnails.collectionView else { return }

        let direction = { () -> ThumbnailLayout.Cell.Direction in
            if indexPath.row + 1 >= collectionView.numberOfItems(inSection: 0) {
                return .left
            } else {
                return .right
            }
        }()

        let expandingIndexPath = { () -> IndexPath in
            switch direction {
            case .left:
                return IndexPath(row: indexPath.row - 1, section: 0)
            case .right:
                return IndexPath(row: indexPath.row + 1, section: 0)
            }
        }()
        deleteItem(at: indexPath, with: rate, expandingIndexPath: expandingIndexPath, animationDirection: direction)
    }

    func deleteItem(at indexPath: IndexPath,
                    with rate: CGFloat,
                    expandingIndexPath: IndexPath,
                    animationDirection: ThumbnailLayout.Cell.Direction) {

        let delete: ThumbnailLayout.UpdateType = .delete(rate, animationDirection)
        let expand: ThumbnailLayout.UpdateType = .expand(rate)

        zip([indexPath, expandingIndexPath], [delete, expand]).forEach { index, update in
            let previousUpdate = thumbnails.config.updates[index]
            thumbnails.config.updates[index] = update.closure + previousUpdate
        }
        self.thumbnails.invalidateLayout()
    }
}
