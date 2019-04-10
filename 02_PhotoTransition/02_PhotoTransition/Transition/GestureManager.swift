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
final class GestureManager: NSObject {
    var transitionContext: UIViewControllerContextTransitioning?
    var animator: TransitionAnimator?
    var allowInteraction: Bool = false

    override init() {}

    func didPanGesture(with panGesture: UIPanGestureRecognizer,
                       animator: TransitionAnimator) {
        guard let contextTransitioning = transitionContext else { return }

        // いろいろ取り出す
        guard let data =  TransitionDatasource(context: contextTransitioning, animator: animator) else {
            return
        }

        // 遷移元は非表示
        data.fromImageView.isHidden = true

        //　アンカーポイントを変更する
        let anchorPoint = CGPoint(x: data.fromImageViewFrame.midX, y: data.fromImageViewFrame.midY)
        let translatedPoint = panGesture.translation(in: data.fromImageView)
        // デルタ（三角形の先）
        var verticalDelta : CGFloat = 0

        //Check if the device is in landscape
        if UIDevice.current.orientation.isLandscape { //横向き
            verticalDelta = translatedPoint.x < 0 ? 0 : translatedPoint.x //
        }
            //Otherwise the device is in any non-landscape orientation
        else {
            // yがマイナスなら０にする
            verticalDelta = translatedPoint.y < 0 ? 0 : translatedPoint.y
        }

        // 背景透明度はviewとverticalDeltaを使って割り出す。
        let backgroundAlpha = backgroundAlphaFor(view: data.fromViewController.view,
                                                 withPanningVerticalDelta: verticalDelta)
        // 遷移元のtopviewをverticalDeltaで縮小させる。
        let scale = scaleFor(view: data.fromViewController.view, withPanningVerticalDelta: verticalDelta)

        //遷移元のtop viewのアルファを変える。
        data.fromViewController.view.alpha = backgroundAlpha

        // animatorからとってきた遷移中のimageview cgaffineTransformのスケールで縮める
        data.transitioningImageView.transform = CGAffineTransform(scaleX: scale, y: scale)

        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x, y: anchorPoint.y + translatedPoint.y - data.transitioningImageView.frame.height * (1 - scale) / 2.0)
        data.transitioningImageView.center = newCenter

        data.toImageView.isHidden = true

        // contectのupdateInteractiveTransitionをしてすると、遷移途中を表せる
        contextTransitioning.updateInteractiveTransition(1 - scale)


        switch panGesture.state {
        case .ended:
            // ジェスチャーの速度をとる。fromeVCから取得する。（ジェスチャーはfromから）
            let velocity = panGesture.velocity(in: data.fromViewController.view)
            // velocityCheck?
            var velocityCheck : Bool = false
            //建かよこか
            if UIDevice.current.orientation.isLandscape {// よこなら
                //
                velocityCheck = velocity.x < 0 || newCenter.x < anchorPoint.x
            }
            else {
                //速度のyが0未満、または新しいyよりアンカーポイントが下のいちにいる=true
                velocityCheck = velocity.y < 0 || newCenter.y < anchorPoint.y
            }

            //速度のyが0未満、または新しい中心地yよりアンカーポイントが下のいちにいる
            if velocityCheck {

                //遷移するにはジェスチャーが足りない！
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        // imageframeをfromのview frameにする。
                        data.transitioningImageView.frame = data.fromImageViewFrame
                        data.fromViewController.view.alpha = 1.0
                },
                    completion: {[weak self] completed in
                        guard let self = self else { return }
                        // toを
                        data.toImageView.isHidden = false
                        data.fromImageView.isHidden = false
                        data.transitioningImageView.removeFromSuperview()
                        animator.transitionImageView = nil
                        // キャンセルする。
                        contextTransitioning.cancelInteractiveTransition()
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                        animator.toDelegate?.transitionDidEnd(in: animator)
                        animator.fromDelegate?.transitionDidEnd(in: animator)
                        self.transitionContext = nil// transitionContextをクリアしている
                })
                return
            }

            //start animation
            let finalTransitionSize = data.toImageViewFrame

            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [],
                           animations: {
                            data.fromViewController.view.alpha = 0
                            data.transitioningImageView.frame = finalTransitionSize
            }, completion: {[weak self] completed in
                guard let self = self else { return }
                data.transitioningImageView.removeFromSuperview()
                data.toImageView.isHidden = false
                data.fromImageView.isHidden = false
                data.toImageView.isHidden = false
                data.fromImageView.isHidden = false

                //普通のtransitonと微妙に実行するのが違うのか。finishInteractiveを呼ぶ必要がある。
                contextTransitioning.finishInteractiveTransition()
                contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)

                animator.toDelegate?.transitionDidEnd(in: animator)
                animator.fromDelegate?.transitionDidEnd(in: animator)
                self.transitionContext = nil
            })
        default:
            break
        }
    }

    func backgroundAlphaFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha:CGFloat = 1.0
        let finalAlpha: CGFloat = 0.0
        let totalAvailableAlpha = startingAlpha - finalAlpha

        let maximumDelta = view.bounds.height / 4.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)

        return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha)
    }

    func scaleFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingScale:CGFloat = 1.0
        let finalScale: CGFloat = 0.5
        let totalAvailableScale = startingScale - finalScale

        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)

        return startingScale - (deltaAsPercentageOfMaximun * totalAvailableScale)
    }
}

extension GestureManager: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        // contextを保持する　transition controller にバインディングして通知する
        self.transitionContext = transitionContext
        // コンテナviewを作る
        let containerView = transitionContext.containerView

        guard let animator = animator else { return }
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

