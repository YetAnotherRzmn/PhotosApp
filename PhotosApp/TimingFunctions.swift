//
//  TimingFunctions.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/28/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit

enum Easing<T: FloatingPoint> {
    case linear
    case easeOut
    case easeInOut

    var function: ((T) -> (T)) {
        switch self {
        case .linear:
            return linear(x:)
        case .easeOut:
            return easeOut(x:)
        case .easeInOut:
            return easeInOut(x:)
        }
    }
}

// swiftlint:disable identifier_name

private func linear<T: FloatingPoint>(x: T) -> T {
    return x
}

private func easeOut<T: FloatingPoint>(x: T) -> T {
    return x * x
}

private func easeInOut<T: FloatingPoint>(x: T) -> T {
    if x < 1 / 2 {
        return 2 * x * x
    } else {
        return (-2 * x * x) + (4 * x) - 1
    }
}

// swiftlint:enable identifier_name
