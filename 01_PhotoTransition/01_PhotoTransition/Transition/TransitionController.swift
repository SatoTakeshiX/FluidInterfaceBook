//
//  TransitionController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

final class TransitionController: NSObject {
    var animator: TransitionAnimator
    let gestureManager: GestureManager

    // contexを保持する
    var transitionContext: UIViewControllerContextTransitioning?
    weak var fromDelegate: TransitionAnimatorDelegate?
    weak var toDelegate: TransitionAnimatorDelegate?

    init(animator: TransitionAnimator = TransitionAnimator(), gestureManager: GestureManager = GestureManager()) {
        self.animator = animator
        self.gestureManager = gestureManager
        super.init()
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.fromDelegate = fromDelegate
        animator.toDelegate = toDelegate
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let tmp = fromDelegate
        animator.fromDelegate = toDelegate
        animator.toDelegate = tmp
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard let animator = animator as? TransitionAnimator else { return nil }
        if !gestureManager.allowInteraction {
            return nil
        }

        self.animator = animator
        return gestureManager
    }
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

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        if gestureManager.allowInteraction {
            if let animation = animationController as? TransitionAnimator {
                gestureManager.animator = animation
            }
            return gestureManager
        } else {
            return nil
        }
    }
}

// これをどこに実装するのか。
// コメントアウトでinteractivieがオフになるのが理想。そうするとデリゲートもここで実装するのがいいかな？

// uidelegatetransitionと一緒に適応するとこっちが優先される
extension TransitionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        // contextを保持する　transition controller にバインディングして通知する
        self.transitionContext = transitionContext
        // コンテナviewを作る
        let containerView = transitionContext.containerView

        guard let data = TransitionDatasource(context: transitionContext, animator: animator) else {
            return
        }

        // animatorに通知
        animator.fromDelegate?.transitionWillStart(in: animator)
        animator.toDelegate?.transitionWillStart(in: animator)
        // refarenceを更新。

        containerView.insertSubview(data.toViewController.view, belowSubview: data.fromViewController.view)

        if animator.transitionImageView == nil {
            let transitionImageView = UIImageView(image: data.fromImageView.image)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = data.fromImageViewFrame
            animator.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
   }
}

