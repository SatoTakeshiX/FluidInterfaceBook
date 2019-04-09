//
//  UISpringTimingParameters+Ex.swift
//  01_HalfModalView
//
//  Created by satoutakeshi on 2019/04/08.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

// https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5
extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}

