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

    init(image: UIImage) {
        self.viewModel = SmoothTransitionDetailViewModel(image: image)
        super.init(nibName: "SmoothTransitionDetailViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        imageView.image = viewModel.image
//        scrollView.delegate = self
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 4.0
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
