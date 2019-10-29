//
//  CellUpdate.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/29/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

extension ThumbnailLayout {

    typealias CellUpdate = (CellState) -> (CellState)

    enum UpdateType {
        case expand(CGFloat)
        case collapse(CGFloat)
        case delete(CGFloat, Direction)

        var closure: CellUpdate {
            return { $0.updated(by: self) }
        }
    }
}

// MARK: - updates api
extension ThumbnailLayout.CellState {

    func updated(by update: ThumbnailLayout.UpdateType) -> ThumbnailLayout.CellState {
        switch update {
        case .collapse(let rate):
            return collapsed(by: rate)
        case .expand(let rate):
            return expanded(by: rate)
        case .delete(let rate, let direction):
            return deleting(by: rate, with: direction)
        }
    }
}

// MARK: - builders
private extension ThumbnailLayout.CellState {

    func expanded(by rate: CGFloat) -> ThumbnailLayout.CellState {
        return ThumbnailLayout.CellState(
            defaultSize: defaultSize,
            aspectRatio: aspectRatio,
            indexPath: indexPath,
            expanding: rate,
            collapsing: collapsing,
            deleting: deleting,
            deletingDirection: deletingDirection)
    }

    func collapsed(by rate: CGFloat) -> ThumbnailLayout.CellState {
        return ThumbnailLayout.CellState(
            defaultSize: defaultSize,
            aspectRatio: aspectRatio,
            indexPath: indexPath,
            expanding: expanding,
            collapsing: rate,
            deleting: deleting,
            deletingDirection: deletingDirection)
    }

    func aspect(by ratio: CGFloat) -> ThumbnailLayout.CellState {
        return ThumbnailLayout.CellState(
            defaultSize: defaultSize,
            aspectRatio: ratio,
            indexPath: indexPath,
            expanding: expanding,
            collapsing: collapsing,
            deleting: deleting,
            deletingDirection: deletingDirection)
    }

    func deleting(by rate: CGFloat,
                  with direction: ThumbnailLayout.Direction) -> ThumbnailLayout.CellState {
        return ThumbnailLayout.CellState(
            defaultSize: defaultSize,
            aspectRatio: aspectRatio,
            indexPath: indexPath,
            expanding: expanding,
            collapsing: collapsing,
            deleting: rate,
            deletingDirection: direction)
    }
}
