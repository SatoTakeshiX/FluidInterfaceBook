//
//  SmoothTransitionDetailViewModel.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/18.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

protocol SmoothTransitionDetailViewModelInputs {
    func didPan(with gestureRecognizer: UIPanGestureRecognizer)
    var transitionController: TransitionController { get }
}

protocol SmoothTransitionDetailViewModelOutputs: AnyObject {
    func imageViewFrameOfTransitioning(in view: UIView, naviBar: UINavigationBar?) -> CGRect
    var beganGesture: (() -> ())? { get set }
}

protocol SmoothTransitionDetailViewModelType {
    var inputs: SmoothTransitionDetailViewModelInputs { get }
    var outputs: SmoothTransitionDetailViewModelOutputs { get }
}

final class SmoothTransitionDetailViewModel: NSObject,
    SmoothTransitionDetailViewModelInputs,
    SmoothTransitionDetailViewModelOutputs,
SmoothTransitionDetailViewModelType {

    let transitionController: TransitionController
    let image: UIImage
    var inputs: SmoothTransitionDetailViewModelInputs { return self }
    var outputs: SmoothTransitionDetailViewModelOutputs { return self }

    init(image: UIImage, transitionController: TransitionController) {
        self.image = image
        self.transitionController = transitionController
    }

    // outputs
    var beganGesture: (() -> ())?

    // TODO: 実装する
    func didPan(with gestureRecognizer: UIPanGestureRecognizer) {

        switch gestureRecognizer.state {
        case .began:
            // navigationControllerで元の画面に戻る指定をする
            transitionController.gestureManager.allowInteraction = true
            beganGesture?()
        case .ended:
            transitionController.gestureManager.allowInteraction = false
            transitionController
                .gestureManager
                .didPanGesture(with: gestureRecognizer,
                               animator: transitionController.animator)
        case .cancelled, .changed, .failed, .possible:
            transitionController
                .gestureManager
                .didPanGesture(with: gestureRecognizer,
                               animator: transitionController.animator)
            break
        }
    }

    func imageViewFrameOfTransitioning(in view: UIView, naviBar: UINavigationBar?) -> CGRect {
        //
        let x: CGFloat = 0.0
        let aspect = image.size.width / image.size.height
        let displayImageSize = CGSize(width: view.frame.width,
                                      height: view.frame.width * aspect)
        let minY = view.frame.height/2 - displayImageSize.height/2 + (naviBar?.frame.height ?? 0.0)



        return CGRect(x: x,
                      y: minY,
                      width: displayImageSize.width,
                      height: displayImageSize.height)
    }



}
