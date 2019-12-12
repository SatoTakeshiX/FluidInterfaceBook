//
//  TransitionAnimatable.swift
//  02_PhotoTransition
//
//  Created by t-sato on 2019/06/03.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

protocol ZoomTransitionAnimatable {
    func transition()
    func convertRreviousRect(from baseView: UIView, target rect: CGRect, to convertView: UIView) -> CGRect
    func makeTargetRectForNextView() -> CGRect
    var animationDuration: TimeInterval { get }
}

extension ZoomTransitionAnimatable {
    var animationDuration: TimeInterval {
        return 0.5
    }
}

