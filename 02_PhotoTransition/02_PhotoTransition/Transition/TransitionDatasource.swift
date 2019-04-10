//
//  TransitionDatasource.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/22.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

struct TransitionDatasource {
    let toViewController: UIViewController
    let toImageView: UIImageView
    let toImageViewFrame: CGRect
    let fromViewController: UIViewController
    let fromImageView: UIImageView
    let fromImageViewFrame: CGRect
    let transitioningImageView: UIImageView

    init?(context: UIViewControllerContextTransitioning,
          animator: TransitionAnimator) {

        guard let toViewController = context.viewController(forKey: .to) else {
            return nil
        }
        self.toViewController = toViewController

        guard let toImageView = animator.toDelegate?.imageViewOfTransitioning() else {
            return nil
        }
        self.toImageView = toImageView

        guard let toImageViewFrame = animator.toDelegate?.imageViewFrameOfTransitioning() else {
            return nil
        }
        self.toImageViewFrame = toImageViewFrame

        guard let fromViewController = context.viewController(forKey: .from) else {
            return nil
        }
        self.fromViewController = fromViewController

        guard let fromImageView = animator.fromDelegate?.imageViewOfTransitioning() else {
            return nil
        }
        self.fromImageView = fromImageView

        guard let fromImageViewFrame = animator.fromDelegate?.imageViewFrameOfTransitioning() else {
            return nil
        }
        self.fromImageViewFrame = fromImageViewFrame

        if let transitionImageView = animator.transitionImageView {
            self.transitioningImageView = transitionImageView
        } else {
            let transitionImageView = UIImageView(image: fromImageView.image)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromImageViewFrame
            self.transitioningImageView = transitionImageView
        }
    }

}
