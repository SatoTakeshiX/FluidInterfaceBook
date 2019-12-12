//
//  TransitionAnimator.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit
import AVFoundation

protocol TransitionAnimatorDelegate: AnyObject {
    func transitionWillStart(in zoomAnimator: TransitionAnimator)
    func transitionDidEnd(in zoomAnimator: TransitionAnimator)
    func imageViewOfTransitioning() -> UIImageView?
    func imageViewFrameOfTransitioning() -> CGRect?
}

final class ZoomTransitionForPresent: NSObject, ZoomTransitionAnimatable {
    func makeTargetRectForNextView() -> CGRect {
        return CGRect()
    }

    func convertRreviousRect(from baseView: UIView, target rect: CGRect, to convertView: UIView) -> CGRect {
        let rect = baseView.convert(rect, to: convertView)
        return rect
    }

    func transition() {}
}

final class TransitionAnimator: NSObject {

    enum TransitionType {
        case present, dismiss
    }

    // 遷移すると元の画面に戻るかを保持する
    private(set) var transitionType: TransitionType = .present

    weak var fromDelegate: TransitionAnimatorDelegate?
    weak var toDelegate: TransitionAnimatorDelegate?

    var transitionImageView: UIImageView?

    func present() {
        transitionType = .present
    }

    func dismiss() {
        transitionType = .dismiss
    }

    private func animateZoomInTransition(context transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView

        guard let toVC = transitionContext.viewController(forKey: .to) as? SmoothTransitionDetailViewController,
            let fromImageView = fromDelegate?.imageViewOfTransitioning(),
            let toImageView = toDelegate?.imageViewOfTransitioning(),
            //let fromReferenceImageViewFrame = self.fromDelegate?.imageViewFrameOfTransitioning(),
            let fromVC = transitionContext.viewController(forKey: .from) as? SmoothTransitionViewController
            else {
                return
        }

        // delegateでとって来てほしいなrect
        fromDelegate?.transitionWillStart(in: self)
        toDelegate?.transitionWillStart(in: self)

        // viewの設定
        toVC.view.alpha = 0
        toImageView.isHidden = true
        containerView.addSubview(toVC.view)

        guard let selectedCell = fromVC.selectedCell else { return }

        // TODO: rectを計算するものを切り出してテストを追加する
        let selectedCellRect = selectedCell.convert(selectedCell.bounds, to: fromVC.view)

        transitionImageView = makeImageViewIfNeeded(origin: transitionImageView, image: fromImageView.image, frame: selectedCellRect)
        containerView.addSubview(transitionImageView!)

        fromImageView.isHidden = true

        // TODO: !を使ったので後でアンラップする
        var finishImageRect = makeZoomInFrame(image: fromImageView.image!, forView: toVC.view)
        finishImageRect = containerView.convert(finishImageRect, to: toVC.navigationController?.view!)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.transitionCrossDissolve],
                       animations: {[weak self] in
                        guard let self = self else { return }
                        self.transitionImageView?.frame = finishImageRect
                        toVC.view.alpha = 1.0
        }, completion: {[weak self] completed in
            guard let self = self else { return }
            self.finishTransition(transitionContext: transitionContext, to: toImageView, fromImageView: fromImageView)
            self.transitionImageView = nil

            })
    }

    private func animateZoomOutTransition(context transitionContext:  UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView

        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromImageView = self.fromDelegate?.imageViewOfTransitioning(),
            let toImageView = self.toDelegate?.imageViewOfTransitioning(),
            let fromImageViewFrame = self.fromDelegate?.imageViewFrameOfTransitioning(),
            let toImageViewFrame = self.toDelegate?.imageViewFrameOfTransitioning()
            else {
                return
        }

        fromDelegate?.transitionWillStart(in: self)
        toDelegate?.transitionWillStart(in: self)

        toImageView.isHidden = true

        transitionImageView = makeImageViewIfNeeded(origin: transitionImageView, image: fromImageView.image, frame: fromImageViewFrame)
        containerView.addSubview(transitionImageView!)
        transitionImageView?.contentMode = .scaleAspectFit

        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        fromImageView.isHidden = true

        let finalTransitionSize = makeDissmissToImageRect(to: toVC, from: fromVC, toImageFrame: toImageViewFrame)// toImageViewFrame

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {[weak self] in
                        guard let self = self else { return }
                        fromVC.view.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
        }, completion: {[weak self] completed in
            guard let self = self else { return }
            self.transitionImageView!.removeFromSuperview()
            toImageView.isHidden = false
            fromImageView.isHidden = false
            self.finishTransition(transitionContext: transitionContext, to: toImageView, fromImageView: fromImageView)
            self.toDelegate?.transitionDidEnd(in: self)
            self.fromDelegate?.transitionDidEnd(in: self)
        })
    }

    private func makeDissmissToImageRect(to toViewController: UIViewController, from fromViewController: UIViewController, toImageFrame: CGRect) -> CGRect {
        guard let subView = toViewController.view.subviews.first else {
            return CGRect()

        }

        let rect = fromViewController.view.convert(toImageFrame, from: subView)

        return rect
    }

    private func makeImageViewIfNeeded(origin imageView: UIImageView?, image: UIImage?, frame: CGRect) -> UIImageView {

        if let imageView = imageView {
            return imageView
        } else {
            let newImageView = UIImageView(image: image)
            newImageView.contentMode = .scaleAspectFill
            newImageView.clipsToBounds = true
            newImageView.frame = frame
            return newImageView
        }
    }

    private func finishTransition(transitionContext: UIViewControllerContextTransitioning, to toImageView: UIImageView, fromImageView: UIImageView) {

        transitionImageView?.removeFromSuperview()
        toImageView.isHidden = false
        fromImageView.isHidden = false
        self.transitionImageView = nil
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        toDelegate?.transitionDidEnd(in: self)
        fromDelegate?.transitionDidEnd(in: self)
    }

    private func makeZoomInFrame(image: UIImage, forView view: UIView) -> CGRect {
        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)

        let newRect = CGRect(x: imageRect.minX, y: imageRect.minY + 26 , width: imageRect.width, height: imageRect.height)

        return newRect
    }
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // TODO: contextがとれる。gestureに更新する？
        switch transitionType {
        case .present:
            return 0.5
        case .dismiss:
            return 0.25
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionType {
        case .present:
            animateZoomInTransition(context: transitionContext)
        case .dismiss:
            animateZoomOutTransition(context: transitionContext)
        }
    }
}
