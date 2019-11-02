//
//  ScrollSynchronizer.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/14/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

enum InteractionState {
    case enabled
    case disabled
}

enum LayoutState {
    case ready
    case configuring
}

protocol LayoutChangeHandler {
    var needsUpdateOffset: Bool { get }
    var targetIndex: Int { get }
    var layoutState: LayoutState { get set }
}

class ScrollSynchronizer: NSObject {
    let preview: PreviewLayout
    let thumbnails: ThumbnailLayout

    var activeIndex = 0
    var layoutStateInternal: LayoutState = .configuring
    var interactionState: InteractionState = .enabled

    init(preview: PreviewLayout, thumbnails: ThumbnailLayout) {
        self.preview = preview
        self.thumbnails = thumbnails
        super.init()
        self.thumbnails.layoutHandler = self
        self.preview.layoutHandler = self
        bind()
    }

    func reload() {
        preview.collectionView?.reloadData()
        thumbnails.collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension ScrollSynchronizer: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collection = scrollView as? UICollectionView else { return }
        unbind()
        if collection == preview.collectionView {
            let offset = scrollView.contentOffset.x
            let relativeOffset = offset / preview.itemSize.width / CGFloat(collection.numberOfItems(inSection: 0))
            thumbnails.changeOffset(relative: relativeOffset)
            activeIndex = thumbnails.nearestIndex
        }
        if scrollView == thumbnails.collectionView {
            print(thumbnails.relativeOffset)
            let index = thumbnails.nearestIndex
            if index != activeIndex {
                activeIndex = index
                let indexPath = IndexPath(row: activeIndex, section: 0)
                preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
        bind()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if activeIndex != indexPath.row {
            activeIndex = indexPath.row
            handle(event: .move(index: indexPath, completion: .none))
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == thumbnails.collectionView {
            handle(event: .beginScrolling)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == thumbnails.collectionView && !decelerate {
            thumbnailEndScrolling()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == thumbnails.collectionView {
            thumbnailEndScrolling()
        }
    }

    func thumbnailEndScrolling() {
        handle(event: .endScrolling)
    }
}

// MARK: - event handling
extension ScrollSynchronizer {
    enum Event {
        case remove(index: IndexPath, dataSourceUpdate: () -> Void, completion: (() -> Void)?)
        case move(index: IndexPath, completion: (() -> Void)?)
        case beginScrolling
        case endScrolling
    }

    func handle(event: Event) {
        switch event {
        case .remove(let index, let update, let completion):
            delete(at: index, dataSourceUpdate: update, completion: completion)
        case .move(let index, let completion):
            move(to: index, completion: completion)
        case .endScrolling:
            endScrolling()
        case .beginScrolling:
            beginScrolling()
        }
    }
}

// MARK: - event handling impl
private extension ScrollSynchronizer {

    func delete(
        at indexPath: IndexPath,
        dataSourceUpdate: @escaping () -> Void,
        completion: (() -> Void)?) {

        unbind()
        interactionState = .disabled
        DeleteAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
            let previousCount = self.thumbnails.itemsCount
            if previousCount == indexPath.row + 1 {
                self.activeIndex = previousCount - 1
            }
            dataSourceUpdate()
            self.thumbnails.collectionView?.deleteItems(at: [indexPath])
            self.preview.collectionView?.deleteItems(at: [indexPath])
            print("removed \(indexPath)")
            self.bind()
            self.interactionState = .enabled
            completion?()
        }
    }

    func move(to indexPath: IndexPath, completion: (() -> Void)?) {

        unbind()
        interactionState = .disabled
        MoveAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
            self.interactionState = .enabled
            self.bind()
        }
    }

    func beginScrolling() {
        interactionState = .disabled
        ScrollAnimation(thumbnails: thumbnails, preview: preview, type: .beign).run {

        }
    }

    func endScrolling() {
        ScrollAnimation(thumbnails: thumbnails, preview: preview, type: .end).run {
            self.interactionState = .enabled
        }
    }
}

// MARK: - layout changes
extension ScrollSynchronizer: LayoutChangeHandler {
    var layoutState: LayoutState {
        get {
            layoutStateInternal
        }
        set(value) {
            switch value {
            case .ready:
                bind()
            case .configuring:
                unbind()
            }
            layoutStateInternal = value
        }
    }

    var needsUpdateOffset: Bool {
        layoutState == .configuring
    }

    var targetIndex: Int {
        activeIndex
    }
}

// MARK: - private
extension ScrollSynchronizer {
    private func bind() {
        preview.collectionView?.delegate = self
        thumbnails.collectionView?.delegate = self
    }

    private func unbind() {
        preview.collectionView?.delegate = .none
        thumbnails.collectionView?.delegate = .none
    }
}
