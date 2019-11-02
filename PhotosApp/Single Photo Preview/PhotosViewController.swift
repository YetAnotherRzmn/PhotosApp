//
//  ViewController.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/11/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    var dataSource: PhotosDataSource?

    var contentView: PhotosView {
        return (view as? PhotosView).require()
    }

    override func loadView() {
        view = PhotosView(sizeForIndex: {
            if let images = self.dataSource?.images {
                return images.count > $0 ? images[$0].size : CGSize(width: 1, height: 1)
            }
            return CGSize(width: 1, height: 1)
        })
        dataSource = PhotosDataSource(preview: contentView.previewCollection,
                                      thumbnails: contentView.thumbnailCollection)
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: .none, action: .none),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd(sender:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onDelete(sender:)))
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.synchronizer.layoutState = .ready
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.synchronizer.layoutState = .configuring
    }

    @objc func onDelete(sender: UIBarButtonItem) {
        guard contentView.synchronizer.interactionState == .enabled else { return }
        let index = contentView.indexInFocus
        let event: ScrollSynchronizer.Event = .remove(
            index: IndexPath(item: index, section: 0),
            dataSourceUpdate: { self.dataSource?.images.remove(at: index) },
            completion: nil)
        contentView.synchronizer.handle(event: event)
    }

    @objc func onAdd(sender: UIBarButtonItem) {
        if let dataSource = dataSource {
            dataSource.images.append(dataSource.randomImage())
            contentView.synchronizer.reload()
        }
    }
}

// MARK: orientation changes
extension PhotosViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        contentView.synchronizer.interactionState = .disabled
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.contentView.synchronizer.interactionState = .enabled
        }
    }
}
