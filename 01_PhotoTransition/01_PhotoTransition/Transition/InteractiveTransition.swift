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
    let animator: TransitionAnimator

    init(animator: TransitionAnimator) {
        self.animator = animator
    }

    func didPangesuture() {

    }
}

