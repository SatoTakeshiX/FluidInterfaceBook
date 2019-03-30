//
//  DrawerBehavior.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

final class DrawerBehavior {
    // Asks the behavior object if the drawer should project a momentum of a user interaction to move the proposed position.
    func shouldProjectMomentum(_ drawerVC: DrawerContainerViewController, for proposedTargetPosition: DrawerPositionType) -> Bool {
        switch (drawerVC.position, proposedTargetPosition) {
        case (.full, .tip):
            return false
        case (.tip,  .full):
            return false
        default:
            return true
        }
    }

    func momentumProjectionRate(_ fpc: DrawerContainerViewController) -> CGFloat {
        return UIScrollView.DecelerationRate.normal.rawValue
    }

    func redirectionalProgress() -> CGFloat {
        return 0.5
    }

    func addAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
    }

    func removeAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
    }

    func moveAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
    }

    var removalVelocity: CGFloat {
        return 10.0
    }

    var removalProgress: CGFloat {
        return 0.5
    }

    func removalInteractionAnimator(with velocity: CGVector) -> UIViewPropertyAnimator {
        let timing = UISpringTimingParameters(dampingRatio: 1.0,
                                              initialVelocity: velocity)
        return UIViewPropertyAnimator(duration: 0, timingParameters: timing)
    }

    func interactionAnimator(to targetPosition: DrawerPositionType, with velocity: CGVector) -> UIViewPropertyAnimator {
        let timing = timeingCurve(with: velocity)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
        animator.isInterruptible = false
        return animator
    }

    private func timeingCurve(with velocity: CGVector) -> UITimingCurveProvider {
        let damping = self.getDamping(with: velocity)
        return UISpringTimingParameters(dampingRatio: damping, initialVelocity: velocity)
    }

    private let velocityThreshold: CGFloat = 8.0
    private func getDamping(with velocity: CGVector) -> CGFloat {
        let dy = abs(velocity.dy)
        if dy > velocityThreshold {
            return 0.7
        } else {
            return 1.0
        }
    }
}


