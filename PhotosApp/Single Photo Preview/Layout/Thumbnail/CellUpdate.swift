//
//  CellUpdate.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/29/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

internal func+<T>(lhs: @escaping (T) -> T,
                  rhs: ((T) -> T)?) -> (T) -> T {
    return { lhs(rhs?($0) ?? $0) }
}

extension ThumbnailLayout {

    typealias CellUpdate = (Cell) -> Cell

    enum UpdateType {
        case expand(CGFloat)
        case collapse(CGFloat)
        case delete(CGFloat, Cell.Direction)

        var closure: CellUpdate {
            return { $0.updated(by: self) }
        }
    }
}

// MARK: - updates api
extension ThumbnailLayout.Cell {

    func updated(by update: ThumbnailLayout.UpdateType) -> ThumbnailLayout.Cell {
        switch update {
        case .collapse(let rate):
            return updated(new: state.collapsed(by: rate))
        case .expand(let rate):
            return updated(new: state.expanded(by: rate))
        case .delete(let rate, let direction):
            return updated(new: state.deleting(by: rate, with: direction))
        }
    }
}

// MARK: - builders
private extension ThumbnailLayout.Cell.State {
    typealias State = ThumbnailLayout.Cell.State

    func expanded(by rate: CGFloat) -> State {
        return State(
            expanding: rate,
            collapsing: collapsing,
            deleting: deleting,
            deletingDirection: deletingDirection)
    }

    func collapsed(by rate: CGFloat) -> State {
        return State(
            expanding: expanding,
            collapsing: rate,
            deleting: deleting,
            deletingDirection: deletingDirection)
    }

    func deleting(by rate: CGFloat,
                  with direction: ThumbnailLayout.Cell.Direction) -> State {
        return State(
            expanding: expanding,
            collapsing: collapsing,
            deleting: rate,
            deletingDirection: direction)
    }
}
