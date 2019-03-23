//
//  SmoothTransitionDetailDetailViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/18.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

/**
 contentOffsetは、どれぐらいスクロールしているか。
 contentInsetは、余分にどれだけスクロールできるか。
 contentSizeは、スクロールする中身のサイズ。
 */

class SmoothTransitionDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    let viewModel: SmoothTransitionDetailViewModel

    // 長押しのジェスチャー
    var panGestureRecognizer: UIPanGestureRecognizer?

    init(image: UIImage, transitionController: TransitionController) {
        self.viewModel = SmoothTransitionDetailViewModel(image: image, transitionController: transitionController)
        super.init(nibName: "SmoothTransitionDetailViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
    }

    @objc private func didPan(with gestureRecognizer: UIPanGestureRecognizer) {

        viewModel.inputs.didPan(with: gestureRecognizer)
    }

    func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(SmoothTransitionDetailViewController.didPan(with:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    private func setupUI() {
        imageView.image = viewModel.image
    }

    private func updateScrollInset() {
        // imageViewの大きさからcontentInsetを再計算
        // なお、0を下回らないようにする
        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - imageView.frame.height)/2, 0),
            left: max((scrollView.frame.width - imageView.frame.width)/2, 0),
            bottom: 0,
            right: 0
        );
    }

}

extension SmoothTransitionDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
    }
}

extension SmoothTransitionDetailViewController: TransitionAnimatorDelegate {
    func transitionWillStart(in zoomAnimator: TransitionAnimator) {

    }

    func transitionDidEnd(in zoomAnimator: TransitionAnimator) {

    }

    func imageViewOfTransitioning() -> UIImageView? {
        return imageView
    }

    func imageViewFrameOfTransitioning() -> CGRect? {
        return viewModel.outputs.imageViewFrameOfTransitioning(in: view, naviBar: navigationController?.navigationBar)
    }
}

extension SmoothTransitionDetailViewController: UIGestureRecognizerDelegate {
    // ジェスチャーを始めるかどうか
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)

            var velocityCheck : Bool = false

            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            if scrollView.contentOffset.y == 0 {
                return true
            }
        }
        return false
    }
}
