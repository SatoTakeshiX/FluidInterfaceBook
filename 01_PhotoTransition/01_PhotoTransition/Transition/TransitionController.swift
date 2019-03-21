//
//  TransitionController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

final class TransitionController: NSObject {
    let animator: TransitionAnimator
//    let interactionController: ZoomDismissalInteractionController
//    var isInteractive: Bool = false

    weak var fromDelegate: TransitionAnimatorDelegate?
    weak var toDelegate: TransitionAnimatorDelegate?

    init(animator: TransitionAnimator = TransitionAnimator()) {
        self.animator = animator
        //interactionController = ZoomDismissalInteractionController()
        super.init()
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //self.animator.isPresenting = true
        animator.fromDelegate = fromDelegate
        animator.toDelegate = toDelegate
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //self.animator.isPresenting = false
        let tmp = fromDelegate
        animator.fromDelegate = toDelegate
        animator.toDelegate = tmp
        return animator
    }

//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        if !self.isInteractive {
//            return nil
//        }
//
//        self.interactionController.animator = animator
//        return self.interactionController
//    }
}

extension TransitionController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            animator.present()
            animator.fromDelegate = fromDelegate
            animator.toDelegate = toDelegate
        case .none, .pop:
            animator.dismiss()
            let tmp = fromDelegate
            animator.fromDelegate = toDelegate
            animator.toDelegate = tmp
        }
        return self.animator
    }

//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
////        if !self.isInteractive {
////            return nil
////        }
//
//        self.interactionController.animator = animator
//        return self.interactionController
//    }


}

// これをどこに実装するのか。
// コメントアウトでinteractivieがオフになるのが理想。そうするとデリゲートもここで実装するのがいいかな？
extension TransitionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        //startInteractiveTransition?(transitionContext)
    }
}
