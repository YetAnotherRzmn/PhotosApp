//
//  ModeAnimator.swift
//  PhotosCollection
//
//  Created by Nikita Razumnuy on 9/25/19.
//  Copyright © 2019 com.rzmn. All rights reserved.
//

import UIKit

protocol ProgressAnimator {
	var progress: CGFloat { get }

	func setProgress(progress: CGFloat, duration: TimeInterval, completion: ((Bool) -> ())?)

	func cancel()
}

protocol TimingFunction {
	func apply(value: CGFloat) -> CGFloat
}

class LinearTimingFunction: TimingFunction {
	func apply(value: CGFloat) -> CGFloat {
		return value
	}
}

class EaseOutTimingFunction: TimingFunction {
	func apply(value: CGFloat) -> CGFloat {
		return value * value
	}
}

class EaseInOutTimingFunction: TimingFunction {
	func apply(value: CGFloat) -> CGFloat {
		if value < 1 / 2 {
			return 2 * value * value
		} else {
			return (-2 * value * value) + (4 * value) - 1
		}
	}
}

class DefaultProgressAnimator {
	var currentProgress: CGFloat = 0

	fileprivate var displayLink: CADisplayLink?
	fileprivate var fromProgress: CGFloat = 0
	fileprivate var toProgress: CGFloat = 0
	fileprivate var startTimeInterval: TimeInterval = 0
	fileprivate var endTimeInterval: TimeInterval = 0

	fileprivate var completion: ((Bool) -> ())?
	fileprivate let onProgress: (CGFloat, CGFloat) -> ()
	fileprivate let timing: TimingFunction

	required init(initial progress: CGFloat,
				  onProgress: @escaping (CGFloat, CGFloat) -> (), easing: TimingFunction = LinearTimingFunction()) {
		self.currentProgress = progress
		self.onProgress = onProgress
		self.timing = easing
	}
}

// MARK ThumbnailFlowLayout.ModeAnimator impl
extension DefaultProgressAnimator: ProgressAnimator {
	var progress: CGFloat {
		return currentProgress
	}

	func setProgress(progress: CGFloat, duration: TimeInterval, completion: ((Bool) -> ())?) {
		if let _ = displayLink {
			self.completion?(false)
		}
		self.completion = completion
		fromProgress = currentProgress
		toProgress = progress
		startTimeInterval = CACurrentMediaTime()
		endTimeInterval = startTimeInterval + duration * TimeInterval(abs(toProgress - fromProgress))

		displayLink?.invalidate()
		displayLink = CADisplayLink(target: self, selector: #selector(onProgressChanged(link:)))
		displayLink?.add(to: .main, forMode: .common)
	}

	func cancel() {
		if let _ = displayLink {
			self.completion?(false)
		}
		displayLink?.invalidate()
		displayLink = nil
	}
}

// MARK: - progress updating timer handler
extension DefaultProgressAnimator {
	@objc func onProgressChanged(link: CADisplayLink) {
		let currentTime = CACurrentMediaTime()
		var currentProgress = CGFloat((currentTime - startTimeInterval) / (endTimeInterval - startTimeInterval))

		currentProgress = min(1, currentProgress)

		let tick = timing.apply(value: currentProgress) - timing.apply(value: self.currentProgress)
		self.currentProgress = fromProgress + (toProgress - fromProgress) * currentProgress

		onProgress(timing.apply(value: self.currentProgress), tick)

		if self.currentProgress >= 1 {
			displayLink?.invalidate()
			displayLink = nil
			completion?(true)
		}
	}
}
