//
//  InteractiveTransition.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/21.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

// こいつの責務ってなんだろう。デリゲートまで担う？それとも？？pangestureを担うだけ？
// controllerからコメントアウトで機能が停止する感じが良い
// pangestureを扱うもので良さそう。
// deleateをtransitioncONTROLLERに任せよう。ここはpangesutyreを呼ぶだけ
final class InteractiveTransition: NSObject {
    var transitionContext: UIViewControllerContextTransitioning?
    //let animator: TransitionAnimator

    override init() {}

    func didPanGesture(with panGesture: UIPanGestureRecognizer,
                       contextTransitioning: UIViewControllerContextTransitioning,
                       animator: TransitionAnimator) {

        // いろいろ取り出す
        // これ型を作ったほうがいいな
        guard let transitionImageView = animator.transitionImageView,
            let fromVC = contextTransitioning.viewController(forKey: .from),
            let toVC = contextTransitioning.viewController(forKey: .to),
            let fromImageView = animator.fromDelegate?.imageViewOfTransitioning(),
            let toImageView = animator.toDelegate?.imageViewOfTransitioning(),//animatorのメソッド引数に自分いれるのへん
            let toImageViewFrame = animator.toDelegate?.imageViewFrameOfTransitioning() ,
            let fromImageViewFrame = animator.fromDelegate?.imageViewFrameOfTransitioning() else {
                return
        }


    }
}

