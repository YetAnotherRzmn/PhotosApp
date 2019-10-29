//
//  ModeAnimator.swift
//  PhotosCollection
//
//  Created by Nikita Razumnuy on 9/25/19.
//  Copyright © 2019 com.rzmn. All rights reserved.
//

import UIKit

class Animator {
    var currentProgress: CGFloat = 0

    fileprivate var displayLink: CADisplayLink?
    fileprivate var fromProgress: CGFloat = 0
    fileprivate var toProgress: CGFloat = 0
    fileprivate var startTimeInterval: TimeInterval = 0
    fileprivate var endTimeInterval: TimeInterval = 0

    fileprivate var completion: ((Bool) -> Void)?
    fileprivate let onProgress: (CGFloat, CGFloat) -> Void
    fileprivate let timing: (CGFloat) -> (CGFloat)

    required init(onProgress: @escaping (CGFloat, CGFloat) -> Void,
                  easing: Easing<CGFloat> = .linear) {

        self.currentProgress = .zero
        self.onProgress = onProgress
        self.timing = easing.function
    }
}

// MARK: - ThumbnailFlowLayout.ModeAnimator impl
extension Animator {

    func animate(duration: TimeInterval, completion: ((Bool) -> Void)?) {
        if displayLink != nil {
            self.completion?(false)
        }
        self.completion = completion
        fromProgress = currentProgress
        toProgress = 1
        startTimeInterval = CACurrentMediaTime()
        endTimeInterval = startTimeInterval + duration * TimeInterval(abs(toProgress - fromProgress))

        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(onProgressChanged(link:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    func cancel() {
        if displayLink != nil {
            self.completion?(false)
        }
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - progress updating timer handler
extension Animator {
    @objc func onProgressChanged(link: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        var currentProgress = CGFloat((currentTime - startTimeInterval) / (endTimeInterval - startTimeInterval))

        currentProgress = min(1, currentProgress)

        let tick = timing(currentProgress) - timing(self.currentProgress)
        self.currentProgress = fromProgress + (toProgress - fromProgress) * currentProgress

        onProgress(timing(self.currentProgress), tick)

        if self.currentProgress >= 1 {
            displayLink?.invalidate()
            displayLink = nil
            completion?(true)
        }
    }
}
