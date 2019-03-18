//
//  SmoothTransitionDetailDetailViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/18.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

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
    }

}

extension SmoothTransitionDetailViewController: TransitionAnimatorDelegate {
    func transitionWillStart(in zoomAnimator: TransitionAnimator) {

    }

    func transitionDidEnd(in zoomAnimator: TransitionAnimator) {

    }

    func imageViewOfTransitioning(in zoomAnimator: TransitionAnimator) -> UIImageView? {
        return imageView
    }

    func imageViewFrameOfTransitioning(in zoomAnimator: TransitionAnimator) -> CGRect? {

        // imageViewのframeではなくて、imageの表示rectが必要。
        // imageは中心に表示している前提。
        // あ、zoomするときどうなんだ？
        // いいや、今は
        let imageSize = imageView.image!.size
        let fromRect = CGRect(origin: CGPoint(x: imageView.frame.maxY/2, y: imageView.frame.maxY/2), size: imageSize)
        let xpoint: CGFloat = 0.0
        let ypoint = (imageView.bounds.maxY - imageSize.height) / 2
        return CGRect(x: xpoint, y: ypoint, width: imageSize.width, height: imageSize.height)
    }


}
